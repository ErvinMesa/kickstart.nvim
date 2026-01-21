return {
  'tpope/vim-fugitive',
  cmd = { 'Git', 'G' },
  keys = {
    { '<leader>gg', '<cmd>Git<CR>', desc = 'Git Status' },
    { '<leader>gb', '<cmd>Git blame<CR>', desc = 'Git Blame' },
    { '<leader>gd', '<cmd>Gvdiffsplit<CR>', desc = 'Git Diff' },
    { '<leader>gr', '<cmd>GDelete<CR>', desc = 'Git Restore' },
  },
}
