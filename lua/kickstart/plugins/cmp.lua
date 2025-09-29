return {
  'hrsh7th/nvim-cmp',
  dependencies = {
    'hrsh7th/cmp-nvim-lsp', -- LSP completions
    'hrsh7th/cmp-buffer', -- Buffer words
    'hrsh7th/cmp-path', -- Filesystem paths
    'hrsh7th/cmp-cmdline', -- : command line
    'L3MON4D3/LuaSnip', -- Snippet engine
    'saadparwaiz1/cmp_luasnip', -- Snippets source
  },
  config = function()
    local cmp = require 'cmp'
    local luasnip = require 'luasnip'

    cmp.setup {
      completion = {
        autocomplete = { cmp.TriggerEvent.TextChanged },
        keyword_length = 2,
      },
      performance = {
        debounce = 200,
        throttle = 100,
      },
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },
      mapping = cmp.mapping.preset.insert {
        ['<C-Space>'] = cmp.mapping.complete(), -- manually trigger
        -- ['<CR>'] = cmp.mapping.confirm { select = true },
        -- ['<Tab>'] = cmp.mapping(function(fallback)
        --   if cmp.visible() then
        --     cmp.select_next_item()
        --   elseif luasnip.expand_or_jumpable() then
        --     luasnip.expand_or_jump()
        --   else
        --     fallback()
        --   end
        -- end, { 'i', 's' }),
        ['<S-Tab>'] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          elseif luasnip.jumpable(-1) then
            luasnip.jump(-1)
          else
            fallback()
          end
        end, { 'i', 's' }),
      },
      sources = cmp.config.sources {
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
        { name = 'buffer' },
        { name = 'path' },
      },
    }

    -- (optional) Cmdline setup
    cmp.setup.cmdline(':', {
      completion = { autocomplete = false },
      mapping = cmp.mapping.preset.cmdline(),
      sources = { { name = 'path' }, { name = 'cmdline' } },
    })
  end,
}
