local eslint_config_markers = {
  'eslint.config.js',
  'eslint.config.mjs',
  'eslint.config.cjs',
  '.eslintrc',
  '.eslintrc.js',
  '.eslintrc.cjs',
  '.eslintrc.json',
  '.eslintrc.yaml',
  '.eslintrc.yml',
}

local ruby_root_markers = {
  'Gemfile',
  'gems.rb',
  '.ruby-version',
  '.rubocop.yml',
  '.standard.yml',
  '.git',
}

local function ruby_lsp_root_dir(bufnr, on_dir)
  on_dir(vim.fs.root(bufnr, ruby_root_markers) or vim.fn.getcwd())
end

local function package_has_eslint_config(root)
  local package_json = root and (root .. '/package.json') or nil
  if not package_json or vim.fn.filereadable(package_json) ~= 1 then
    return false
  end

  local ok_read, lines = pcall(vim.fn.readfile, package_json)
  if not ok_read then
    return false
  end

  local ok_decode, package = pcall(vim.json.decode, table.concat(lines, '\n'), { luanil = { object = true } })
  return ok_decode and type(package) == 'table' and type(package.eslintConfig) == 'table'
end

local servers = {
  -- ... etc. See `:help lspconfig-all` for a list of all the pre-configured LSPs
  -- Some languages (like typescript) have entire language plugins that can be useful:
  --    https://github.com/pmizio/typescript-tools.nvim

  lua_ls = {
    settings = {
      Lua = {
        runtime = {
          version = 'LuaJIT',
        },
      },
    },
  },

  intelephense = {
    settings = {
      intelephense = {
        stubs = {
          'apache', 'bcmath', 'bz2', 'calendar', 'com_dotnet', 'Core', 'ctype', 'curl', 'date',
          'dba', 'dom', 'enchant', 'exif', 'FFI', 'fileinfo', 'filter', 'fpm', 'ftp', 'gd',
          'gettext', 'gmp', 'hash', 'iconv', 'imap', 'intl', 'json', 'ldap', 'libxml',
          'mbstring', 'meta', 'mysqli', 'oci8', 'odbc', 'openssl', 'pcntl', 'pcre',
          'PDO', 'pdo_ibm', 'pdo_mysql', 'pdo_pgsql', 'pdo_sqlite', 'pgsql', 'Phar',
          'posix', 'pspell', 'readline', 'Reflection', 'session', 'shmop', 'SimpleXML',
          'snmp', 'soap', 'sockets', 'sodium', 'SPL', 'sqlite3', 'standard', 'superglobals',
          'sysvmsg', 'sysvsem', 'sysvshm', 'tidy', 'tokenizer', 'xml', 'xmlreader',
          'xmlrpc', 'xmlwriter', 'xsl', 'Zend OPcache', 'zip', 'zlib',
          'redis', 'imagick', 'swoole',
        },
        files = {
          maxSize = 5000000,
        },
      },
    },
  },

  html = {},
  dockerls = {},
  docker_compose_language_service = {},
  rust_analyzer = {},

  gopls = {
    settings = {
      gopls = {
        staticcheck = true,
        completeUnimported = true,
        usePlaceholders = true,
        analyses = {
          unusedparams = true,
          shadow = true,
          nilness = true,
          unusedwrite = true,
          useany = true,
        },
        hints = {
          assignVariableTypes = true,
          compositeLiteralFields = true,
          compositeLiteralTypes = true,
          constantValues = true,
          functionTypeParameters = true,
          parameterNames = true,
          rangeVariableTypes = true,
        },
      },
    },
  },

  eslint = {
    root_dir = function(bufnr, on_dir)
      if vim.fs.root(bufnr, { 'deno.json', 'deno.jsonc', 'deno.lock' }) then
        return
      end

      local root = vim.fs.root(bufnr, eslint_config_markers)
      if not root then
        local package_root = vim.fs.root(bufnr, { 'package.json' })
        if package_has_eslint_config(package_root) then
          root = package_root
        end
      end
      if type(root) == 'string' and root ~= '' then
        on_dir(root)
      end
    end,
  },

  emmet_ls = {
    filetypes = { 'css', 'eruby', 'html', 'javascript', 'javascriptreact', 'typescriptreact' },
    init_options = {
      html = {
        options = {
          ['bem.enabled'] = true,
        },
      },
    },
  },
}

if package.config:sub(1, 1) == '/' then
  servers.ruby_lsp = {
    root_dir = ruby_lsp_root_dir,
    single_file_support = true,
    init_options = {
      formatter = 'auto',
      linters = { 'rubocop' },
    },
    settings = {
      rubyLsp = {
        formatter = 'auto',
        linters = { 'rubocop' },
        pullDiagnosticsOn = 'save',
        indexing = {
          excludedPatterns = {
            '.git',
            'log',
            'node_modules',
            'tmp',
            'vendor/bundle',
          },
        },
        featuresConfiguration = {
          codeLens = {
            enableAll = false,
            enableTestCodeLens = false,
          },
          inlayHint = {
            enableAll = false,
          },
        },
        enabledFeatures = {
          codeActions = true,
          codeLens = false,
          completion = true,
          definition = true,
          diagnostics = true,
          documentHighlights = false,
          documentLink = true,
          documentSymbols = true,
          foldingRanges = false,
          formatting = true,
          hover = true,
          inlayHint = false,
          onTypeFormatting = false,
          selectionRanges = true,
          semanticHighlighting = false,
          signatureHelp = true,
          typeHierarchy = false,
          workspaceSymbol = true,
        },
      },
    },
  }
end

return servers
