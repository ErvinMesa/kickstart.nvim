return {
  'windwp/nvim-ts-autotag',
  ft = { 'eruby', 'html', 'javascriptreact', 'typescriptreact' },
  config = function()
    require('nvim-ts-autotag').setup()
  end,
}
