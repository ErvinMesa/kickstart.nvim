local eslint_root_markers = {
  'package-lock.json',
  'yarn.lock',
  'pnpm-lock.yaml',
  'bun.lockb',
  'bun.lock',
  '.git',
}

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

      local root = vim.fs.root(bufnr, eslint_root_markers) or vim.fn.getcwd()
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
  servers.ruby_lsp = {}
  servers.rubocop = {}
end

return servers
