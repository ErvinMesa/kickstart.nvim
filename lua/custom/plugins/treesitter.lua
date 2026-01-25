-- Optimized Treesitter configuration for performance
-- Focus: Reduced parser count, lazy loading, and smart highlighting

return {
  'nvim-treesitter/nvim-treesitter',
  event = { 'BufReadPost', 'BufNewFile' },
  build = ':TSUpdate',
  lazy = false,
  opts = {
    ensure_installed = {
      'bash',
      'lua',
      'vim',
      'vimdoc',
      'html',
      'javascript',
      'typescript',
      'tsx',
      'json',
      'yaml',
      'markdown',
      'markdown_inline',
      'php',
      'phpdoc',
    },
    auto_install = false,
    sync_install = false,
    ignore_install = {},
    highlight = {
      enable = true,
      disable = function(lang, bufnr)
        -- Disable for large files
        local max_filesize = 500 * 1024 -- 500 KB
        local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(bufnr))
        if ok and stats and stats.size > max_filesize then
          return true
        end
        return false
      end,
      additional_vim_regex_highlighting = false,
    },
    indent = {
      enable = true,
      disable = { 'ruby' },
    },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = 'gnn',
        node_incremental = 'grn',
        scope_incremental = 'grc',
        node_decremental = 'grm',
      },
    },
  },
  config = function()
    require('telescope').setup {
      defaults = {
        preview = {
          treesitter = false,
        },
      },
    }
  end,
}
