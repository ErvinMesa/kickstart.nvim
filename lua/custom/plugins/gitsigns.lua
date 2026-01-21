return {
  'lewis6991/gitsigns.nvim',
  event = { 'BufReadPost', 'BufNewFile', 'BufWritePost' },
  config = function()
    require('gitsigns').setup()
  end,
}
