local function file_exists(path)
  local uv = vim.uv or vim.loop
  return type(path) == 'string' and path ~= '' and uv.fs_stat(path) ~= nil
end

local function decode_json_file(path)
  if vim.fn.filereadable(path) ~= 1 then
    return nil
  end

  local ok_read, lines = pcall(vim.fn.readfile, path)
  if not ok_read or type(lines) ~= 'table' then
    return nil
  end

  local ok_decode, decoded = pcall(vim.json.decode, table.concat(lines, '\n'), { luanil = { object = true } })
  if not ok_decode or type(decoded) ~= 'table' then
    return nil
  end

  return decoded
end

local function project_uses_bun(root)
  if type(root) ~= 'string' or root == '' then
    return false
  end

  if file_exists(root .. '/bun.lock') or file_exists(root .. '/bun.lockb') or file_exists(root .. '/bunfig.toml') then
    return true
  end

  local package_json = decode_json_file(root .. '/package.json')
  local package_manager = package_json and package_json.packageManager
  if type(package_manager) == 'string' and package_manager:match '^bun@' then
    return true
  end

  return false
end

local function read_package_imports(root)
  local package_json = decode_json_file(root .. '/package.json')
  local imports = package_json and package_json.imports
  if type(imports) ~= 'table' then
    return {}
  end

  local result = {}
  for key, value in pairs(imports) do
    if type(key) == 'string' and key:sub(1, 1) == '#' then
      if type(value) == 'string' then
        result[key] = value
      elseif type(value) == 'table' then
        if type(value.default) == 'string' then
          result[key] = value.default
        elseif type(value.import) == 'string' then
          result[key] = value.import
        elseif type(value.bun) == 'string' then
          result[key] = value.bun
        end
      end
    end
  end

  return result
end

local function imports_to_ts_paths(imports)
  local paths = {}
  for key, value in pairs(imports) do
    if type(value) == 'string' then
      paths[key] = { value }
      -- Bun users commonly write "#/*". Keep a fallback alias for older TS behavior.
      if key == '#/*' then
        paths['#*'] = { value }
      end
    end
  end
  return paths
end

local function get_root_absolute(root_dir)
  if root_dir and type(root_dir.absolute) == 'function' then
    local ok_root, root = pcall(root_dir.absolute, root_dir)
    if ok_root and type(root) == 'string' then
      return root
    end
  end
  return nil
end

local function read_typescript_version_from_tsserver(tsserver_path)
  local dir = vim.fs.dirname(tsserver_path)
  if not dir then
    return 0, 0
  end

  local package_json_path = vim.fs.dirname(dir) .. '/package.json'
  local package_json = decode_json_file(package_json_path)
  local version = package_json and package_json.version
  if type(version) ~= 'string' then
    return 0, 0
  end

  local major, minor = version:match '^(%d+)%.(%d+)'
  return tonumber(major) or 0, tonumber(minor) or 0
end

local function patch_tsserver_provider_for_bun()
  local ok_provider, provider_mod = pcall(require, 'typescript-tools.tsserver_provider')
  if not ok_provider or type(provider_mod) ~= 'table' or provider_mod.__bun_provider_patch then
    return
  end

  local Path = require 'plenary.path'
  local original_get_executable_path = provider_mod.get_executable_path

  local function add_path_candidate(candidates, p)
    if type(p) ~= 'string' or p == '' then
      return
    end
    if file_exists(p) then
      candidates[#candidates + 1] = p
    end
  end

  local function get_tsserver_candidates(self)
    local candidates = {}
    local root = get_root_absolute(self.root_dir)

    if root then
      add_path_candidate(candidates, root .. '/node_modules/typescript/lib/tsserver.js')
    end

    if self.npm_local_path and type(self.npm_local_path.joinpath) == 'function' then
      add_path_candidate(candidates, self.npm_local_path:joinpath('typescript', 'lib', 'tsserver.js'):absolute())
    end

    if self.yarn_sdk_path and type(self.yarn_sdk_path.joinpath) == 'function' then
      add_path_candidate(candidates, self.yarn_sdk_path:joinpath('typescript', 'lib', 'tsserver.js'):absolute())
    end

    local bun_install = vim.env.BUN_INSTALL or ((vim.env.HOME or '') .. '/.bun')
    add_path_candidate(candidates, bun_install .. '/install/global/node_modules/typescript/lib/tsserver.js')

    local mason_tsserver = vim.fn.stdpath 'data' .. '/mason/packages/typescript-language-server/node_modules/typescript/lib/tsserver.js'
    add_path_candidate(candidates, mason_tsserver)

    if provider_mod.npm_global_path and type(provider_mod.npm_global_path.joinpath) == 'function' then
      add_path_candidate(candidates, provider_mod.npm_global_path:joinpath('typescript', 'lib', 'tsserver.js'):absolute())
    end

    if self.global_install_path and type(self.global_install_path.joinpath) == 'function' then
      add_path_candidate(candidates, self.global_install_path:joinpath('lib', 'tsserver.js'):absolute())
      add_path_candidate(candidates, self.global_install_path:joinpath('lib', 'node_modules', 'typescript', 'lib', 'tsserver.js'):absolute())
    end

    return candidates
  end

  provider_mod.get_executable_path = function(self)
    local root = get_root_absolute(self.root_dir)
    if root and project_uses_bun(root) then
      local preferred = nil
      local preferred_major = 0
      local preferred_minor = 0
      for _, tsserver_path in ipairs(get_tsserver_candidates(self)) do
        local major, minor = read_typescript_version_from_tsserver(tsserver_path)
        if major >= 5 and (not preferred or major > preferred_major or (major == preferred_major and minor > preferred_minor)) then
          preferred = tsserver_path
          preferred_major = major
          preferred_minor = minor
        end
      end

      if preferred then
        return Path:new(preferred)
      end
    end

    return original_get_executable_path(self)
  end

  provider_mod.__bun_provider_patch = true
end

local function patch_inferred_compiler_options_for_bun()
  local ok_initialize, initialize = pcall(require, 'typescript-tools.protocol.initialize')
  if not ok_initialize or type(initialize) ~= 'table' or initialize.__bun_inferred_patch then
    return
  end

  local c = require 'typescript-tools.protocol.constants'
  local make_capabilities = require 'typescript-tools.capabilities'
  local TsserverProvider = require 'typescript-tools.tsserver_provider'

  local default_compiler_options = {
    module = 'ESNext',
    target = 'ES2020',
    jsx = 'react',
    allowJs = true,
    strictNullChecks = true,
    sourceMap = true,
    allowSyntheticDefaultImports = true,
    allowNonTsExtensions = true,
    resolveJsonModule = true,
    moduleResolution = 'Node16',
    resolvePackageJsonImports = true,
    resolvePackageJsonExports = true,
    strictFunctionTypes = true,
  }

  local bun_compiler_options = vim.tbl_extend('force', {}, default_compiler_options, {
    moduleResolution = 'Bundler',
    customConditions = { 'bun' },
    allowImportingTsExtensions = true,
    allowArbitraryExtensions = true,
  })

  local function can_use_bundler_module_resolution(provider)
    if not provider or type(provider.get_version) ~= 'function' then
      return true
    end
    local ok_version, version = pcall(provider.get_version, provider)
    if not ok_version or type(version) ~= 'table' then
      return true
    end

    local major = tonumber(version.major) or 0
    local minor = tonumber(version.minor) or 0
    return major > 5 or (major == 5 and minor >= 0)
  end

  local function read_tsconfig_compiler_options(provider)
    if not provider or type(provider.get_tsconfig_path) ~= 'function' then
      return nil
    end

    local ok_path, config_path = pcall(provider.get_tsconfig_path, provider)
    if not ok_path or not config_path then
      return nil
    end

    local ok_read, raw = pcall(config_path.read, config_path)
    if not ok_read or type(raw) ~= 'string' or raw == '' then
      return nil
    end

    local ok_decode, config = pcall(vim.json.decode, raw, { luanil = { object = true } })
    if not ok_decode or type(config) ~= 'table' then
      return nil
    end

    return type(config.compilerOptions) == 'table' and config.compilerOptions or nil
  end

  local function inferred_compiler_options()
    local provider = TsserverProvider.get_instance()
    local root = provider and get_root_absolute(provider.root_dir) or nil
    local prefers_bun = root and project_uses_bun(root) and can_use_bundler_module_resolution(provider)

    local base = prefers_bun and bun_compiler_options or default_compiler_options
    local from_tsconfig = read_tsconfig_compiler_options(provider)
    local options = vim.tbl_extend('force', {}, base, from_tsconfig or {})

    if root then
      local paths_from_imports = imports_to_ts_paths(read_package_imports(root))
      if next(paths_from_imports) ~= nil then
        options.baseUrl = options.baseUrl or '.'
        options.paths = vim.tbl_extend('force', options.paths or {}, paths_from_imports)
      end
    end

    return options
  end

  initialize.handler = function(request, response)
    request {
      command = c.CommandTypes.Configure,
      arguments = {
        hostInfo = 'neovim',
        preferences = {
          providePrefixAndSuffixTextForRename = true,
          allowRenameOfImportPath = true,
          includePackageJsonAutoImports = 'auto',
          includeCompletionsForModuleExports = false,
          includeCompletionsWithSnippetText = false,
        },
        watchOptions = {
          watchFile = 'useFsEvents',
          watchDirectory = 'useFsEvents',
          fallbackPolling = 'dynamicPriority',
          synchronousWatchDirectory = false,
          excludeDirectories = {
            '**/.git',
            '**/.next',
            '**/.nuxt',
            '**/build',
            '**/coverage',
            '**/dist',
            '**/node_modules',
            '**/tmp',
          },
        },
      },
    }

    request {
      command = c.CommandTypes.CompilerOptionsForInferredProjects,
      arguments = {
        options = inferred_compiler_options(),
      },
    }

    coroutine.yield()
    response { capabilities = make_capabilities() }
  end

  initialize.__bun_inferred_patch = true
end

return {
  'pmizio/typescript-tools.nvim',
  ft = { 'typescript', 'typescriptreact', 'javascript', 'javascriptreact' },
  dependencies = { 'nvim-lua/plenary.nvim', 'neovim/nvim-lspconfig' },
  opts = function()
    local ts_root_markers = {
      'tsconfig.json',
      'jsconfig.json',
      'package.json',
      'bunfig.toml',
      'bun.lockb',
      'bun.lock',
    }

    local function find_root_for_path(path, markers)
      if type(path) ~= 'string' or path == '' then
        return nil
      end
      if path:match '^%a+://' then
        path = vim.uri_to_fname(path)
      end
      local start = vim.fn.isdirectory(path) == 1 and path or vim.fs.dirname(path)
      if not start or start == '' then
        return nil
      end
      local match = vim.fs.find(markers, { path = start, upward = true })[1]
      return match and vim.fs.dirname(match) or nil
    end

    local function roots_from_arg(arg)
      if type(arg) == 'number' then
        return vim.fs.root(arg, ts_root_markers), vim.fs.root(arg, { 'deno.json', 'deno.jsonc' }), vim.fs.root(arg, { 'deno.lock' })
      end

      return find_root_for_path(arg, ts_root_markers), find_root_for_path(arg, { 'deno.json', 'deno.jsonc' }), find_root_for_path(arg, { 'deno.lock' })
    end

    local function resolve_project_root(arg)
      local project_root, deno_root, deno_lock_root = roots_from_arg(arg)

      if deno_lock_root and (not project_root or #deno_lock_root > #project_root) then
        return nil
      end
      if deno_root and (not project_root or #deno_root >= #project_root) then
        return nil
      end

      return project_root
    end

    local function root_dir(arg, on_dir)
      local root = resolve_project_root(arg)
      if type(on_dir) == 'function' then
        if root and root ~= '' then
          on_dir(root)
        end
        return
      end
      return root
    end

    return {
      root_dir = root_dir,
      single_file_support = false,
      on_attach = function(client)
        -- Treesitter already handles highlighting; TS semantic tokens add expensive full-buffer requests.
        client.server_capabilities.semanticTokensProvider = nil
      end,
      settings = {
        separate_diagnostic_server = true,
        publish_diagnostic_on = 'insert_leave',
        tsserver_max_memory = 4096,
        include_completions_with_insert_text = true,
        complete_function_calls = false,
        code_lens = 'off',
        disable_member_code_lens = true,
        expose_as_code_action = {
          'fix_all',
          'add_missing_imports',
          'remove_unused_imports',
          'organize_imports',
        },
        tsserver_watch_options = {
          watchFile = 'useFsEvents',
          watchDirectory = 'useFsEvents',
          fallbackPolling = 'dynamicPriority',
          synchronousWatchDirectory = false,
          excludeDirectories = {
            '**/.git',
            '**/.next',
            '**/.nuxt',
            '**/build',
            '**/coverage',
            '**/dist',
            '**/node_modules',
            '**/tmp',
          },
        },
        tsserver_file_preferences = function()
          return {
            includePackageJsonAutoImports = 'auto',
            includeCompletionsForModuleExports = false,
            includeCompletionsForImportStatements = true,
            includeCompletionsWithSnippetText = false,
            allowRenameOfImportPath = true,
            quotePreference = 'auto',
            importModuleSpecifierEnding = 'auto',
          }
        end,
      },
    }
  end,
  config = function(_, opts)
    patch_tsserver_provider_for_bun()
    patch_inferred_compiler_options_for_bun()
    require('typescript-tools').setup(opts)

    vim.api.nvim_create_user_command('TSToolsTsserverPath', function()
      local ok_provider, provider_mod = pcall(require, 'typescript-tools.tsserver_provider')
      if not ok_provider or type(provider_mod.get_instance) ~= 'function' then
        vim.notify('typescript-tools provider not available', vim.log.levels.WARN)
        return
      end

      local instance = provider_mod.get_instance()
      if not instance or type(instance.get_executable_path) ~= 'function' then
        vim.notify('typescript-tools server is not initialized for current buffer', vim.log.levels.WARN)
        return
      end

      local ok_path, tsserver_path = pcall(function()
        return instance:get_executable_path():absolute()
      end)
      if not ok_path or type(tsserver_path) ~= 'string' then
        vim.notify('Unable to resolve tsserver path', vim.log.levels.ERROR)
        return
      end

      vim.notify('tsserver: ' .. tsserver_path, vim.log.levels.INFO)
    end, { desc = 'Show active tsserver.js path for typescript-tools' })
  end,
}
