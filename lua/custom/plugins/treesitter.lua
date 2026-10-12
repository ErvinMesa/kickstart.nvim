-- Optimized Treesitter configuration for performance
-- Focus: Reduced parser count, lazy loading, and smart highlighting

return {
  'nvim-treesitter/nvim-treesitter',
  branch = 'master', -- This configuration uses the configs.setup API.
  event = { 'BufReadPost', 'BufNewFile' },
  build = ':TSUpdate',
  opts = {
    ensure_installed = {
      'bash',
      'c',
      'cpp',
      'lua',
      'vim',
      'vimdoc',
      'html',
      'css',
      'scss',
      'blade',
      'python',
      'go',
      'gomod',
      'gowork',
      'gosum',
      'embedded_template',
      'javascript',
      'typescript',
      'tsx',
      'json',
      'yaml',
      'markdown',
      'markdown_inline',
      'php',
      'php_only',
      'phpdoc',
      'ruby',
    },
    auto_install = false,
    sync_install = false,
    ignore_install = {},
    highlight = {
      enable = true,
      disable = function(lang, bufnr)
        local max_filesize = 500 * 1024 -- 500 KB
        if vim.tbl_contains({ 'javascript', 'ruby', 'tsx', 'typescript' }, lang) then
          max_filesize = 300 * 1024
        end

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
      disable = { 'javascript', 'ruby', 'tsx', 'typescript' },
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
  config = function(_, opts)
    -- Apply nvim-treesitter configuration
    require('nvim-treesitter.configs').setup(opts)
  end,
}
