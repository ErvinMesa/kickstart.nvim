return {
  'ThePrimeagen/harpoon',
  branch = 'harpoon2',
  dependencies = { 'nvim-lua/plenary.nvim' },
  keys = {
    { '<leader>h', '<cmd>lua require("harpoon.ui").toggle_quick_menu()<CR>', desc = 'Harpoon Menu' },
    { '<leader>ha', '<cmd>lua require("harpoon.mark").add_file()<CR>', desc = 'Harpoon Add' },
    { '<leader>h1', '<cmd>lua require("harpoon.ui").nav_file(1)<CR>', desc = 'Harpoon File 1' },
    { '<leader>h2', '<cmd>lua require("harpoon.ui").nav_file(2)<CR>', desc = 'Harpoon File 2' },
    { '<leader>h3', '<cmd>lua require("harpoon.ui").nav_file(3)<CR>', desc = 'Harpoon File 3' },
    { '<leader>h4', '<cmd>lua require("harpoon.ui").nav_file(4)<CR>', desc = 'Harpoon File 4' },
  },
  config = function()
    require('harpoon').setup()
  end,
}
