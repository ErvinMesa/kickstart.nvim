local servers = {
  -- ... etc. See `:help lspconfig-all` for a list of all the pre-configured LSPs
  -- Some languages (like typescript) have entire language plugins that can be useful:
  --    https://github.com/pmizio/typescript-tools.nvim

  lua_ls = {
    cmd = { 'lua-language-server' },
    filetypes = { 'lua' },
    root_markers = { '.luarc.json', '.luarc.jsonc', '.git' },
    settings = {
      Lua = {
        runtime = {
          version = 'LuaJIT',
        },
      },
    },
  },
  intelephense = {},
  html = {},
  dockerls = {},
  docker_compose_language_service = {},
  rust_analyzer = {},
  prettier = {},
  gopls = {},
  eslint = {},
  emmet_ls = {
    filetypes = { 'css', 'eruby', 'html', 'javascript', 'javascriptreact', 'typescriptreact' },
    init_options = {
      html = {
        options = {
          ['bem.enabled'] = true,
        },
      },
    },
  },
}

local linux_servers = {
  ruby_lsp = {},
  rubocop = {},
}

if package.config:sub(1, 1) == '/' then
  for i = 1, #linux_servers do
    servers[#servers + 1] = linux_servers[i]
  end
end
return servers
