return {
  'stevearc/conform.nvim',
  event = { 'BufWritePre' },
  cmd = { 'ConformInfo' },
  keys = {
    {
      '<leader>f',
      function()
        require('conform').format { async = true, lsp_format = 'fallback' }
      end,
      mode = '',
      desc = '[F]ormat buffer',
    },
  },
  opts = function()
    return {
      format_on_save = {
        async = false,
        timeout_ms = 3000,
        lsp_format = 'fallback',
      },
      formatters_by_ft = {
        c = { 'clang_format' },
        cpp = { 'clang_format' },
        javascript = { 'prettierd', 'prettier', stop_after_first = true },
        javascriptreact = { 'prettierd', 'prettier', stop_after_first = true },
        json = { 'prettierd', 'prettier', stop_after_first = true },
        jsonc = { 'prettierd', 'prettier', stop_after_first = true },
        lua = { 'stylua' },
        css = { 'prettierd', 'prettier', stop_after_first = true },
        scss = { 'prettierd', 'prettier', stop_after_first = true },
        html = { 'prettierd', 'prettier', stop_after_first = true },
        yaml = { 'prettierd', 'prettier', stop_after_first = true },
        markdown = { 'prettierd', 'prettier', stop_after_first = true },
        php = { 'pint', 'php_cs_fixer', stop_after_first = true },
        blade = { 'blade-formatter' },
        eruby = { 'htmlbeautifier' },
        ruby = function(bufnr)
          if vim.fs.root(bufnr, { '.standard.yml' }) then
            return { 'standardrb' }
          end
          return { 'rubocop' }
        end,
        python = { 'ruff_organize_imports', 'ruff_format' },
        go = { 'goimports', 'gofmt' },
        typescript = { 'prettierd', 'prettier', stop_after_first = true },
        typescriptreact = { 'prettierd', 'prettier', stop_after_first = true },
      },
      formatters = {
        pint = {
          -- Only choose Pint when this project installs it, not a global copy.
          command = require('conform.util').find_executable({ 'vendor/bin/pint' }, ''),
          condition = function(self, ctx)
            return self.command(self, ctx) ~= ''
          end,
          cwd = require('conform.util').root_file { 'composer.json' },
        },
        rubocop = { prefer_local = 'bin' },
        standardrb = { prefer_local = 'bin' },
        htmlbeautifier = { prefer_local = 'bin' },
        ['blade-formatter'] = { prefer_local = 'node_modules/.bin' },
        ruff_format = { prefer_local = '.venv/bin' },
        ruff_organize_imports = { prefer_local = '.venv/bin' },
      },
      notify_on_error = true,
    }
  end,
}
