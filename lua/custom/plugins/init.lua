-- Custom optimized plugins loaded via lazy.nvim
-- These override the default kickstart configurations with performance optimizations

return {
  require 'custom.plugins.lazydev',
  require 'custom.plugins.conform',
  require 'custom.plugins.kanagawa',
  require 'custom.plugins.todo-comments',
  require 'custom.plugins.mini',
  require 'custom.plugins.nvim-ts-autotag',
  require 'custom.plugins.diffview',
  require 'custom.plugins.typescript-tools',
  require 'custom.plugins.claude-code',
  require 'custom.plugins.undotree',
  require 'custom.plugins.fugitive',
  require 'custom.plugins.neo-tree',
  require 'custom.plugins.treesitter',
  require 'custom.plugins.cmp',
  require 'custom.plugins.telescope',
}
