return {
  'ThePrimeagen/harpoon',
  branch = 'harpoon2',
  dependencies = { 'nvim-lua/plenary.nvim' },
  keys = {
    { '<leader>a', desc = 'Harpoon add file' },
    { '<C-e>', desc = 'Harpoon menu' },
    { '<C-h>', desc = 'Harpoon file 1' },
    { '<C-j>', desc = 'Harpoon file 2' },
    { '<C-k>', desc = 'Harpoon file 3' },
    { '<C-l>', desc = 'Harpoon file 4' },
    { '<C-b>', desc = 'Harpoon file 5' },
    { '<C-n>', desc = 'Harpoon file 6' },
    { '<C-m>', desc = 'Harpoon file 7' },
    { '<C-S-P>', desc = 'Harpoon previous' },
    { '<C-S-N>', desc = 'Harpoon next' },
  },
  config = function()
    local harpoon = require 'harpoon'
    harpoon:setup {
      settings = {
        save_on_toggle = true,
      },
    }
    vim.keymap.set('n', '<leader>a', function()
      harpoon:list():add()
    end)
    vim.keymap.set('n', '<C-e>', function()
      harpoon.ui:toggle_quick_menu(harpoon:list())
    end)

    vim.keymap.set('n', '<C-h>', function()
      harpoon:list():select(1)
    end)
    vim.keymap.set('n', '<C-j>', function()
      harpoon:list():select(2)
    end)
    vim.keymap.set('n', '<C-k>', function()
      harpoon:list():select(3)
    end)
    vim.keymap.set('n', '<C-l>', function()
      harpoon:list():select(4)
    end)
    vim.keymap.set('n', '<C-b>', function()
      harpoon:list():select(5)
    end)
    vim.keymap.set('n', '<C-n>', function()
      harpoon:list():select(6)
    end)
    vim.keymap.set('n', '<C-m>', function()
      harpoon:list():select(7)
    end)

    -- Toggle previous & next buffers stored within Harpoon list
    vim.keymap.set('n', '<C-S-P>', function()
      harpoon:list():prev()
    end)
    vim.keymap.set('n', '<C-S-N>', function()
      harpoon:list():next()
    end)
  end,
}
