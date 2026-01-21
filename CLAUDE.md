# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a Neovim configuration based on kickstart.nvim - a single-file, well-documented starting point for Neovim. The configuration has been extended with additional plugins and custom settings while maintaining the kickstart philosophy of clarity and simplicity.

## Development Commands

### Formatting
```bash
stylua .
```
Formats all Lua files using StyLua according to `.stylua.toml` (2-space indents, single quotes preferred).

### Testing Changes
After making changes to the configuration:
1. Restart Neovim: `:q` then `nvim`
2. Check plugin status: `:Lazy`
3. Update plugins: `:Lazy update`
4. Check LSP status: `:LspInfo`
5. Check health: `:checkhealth`

### Plugin Management (Lazy.nvim)
- `:Lazy` - View plugin status
- `:Lazy sync` - Install missing plugins, update existing ones, and clean removed ones
- `:Lazy clean` - Remove unused plugins
- `:Lazy update` - Update plugins

### Mason (LSP/Formatter Management)
- `:Mason` - Open Mason UI to manage LSP servers, formatters, and linters
- Tools are auto-installed based on `lua/kickstart/plugins/lspconfig/servers.lua`

## Architecture

### Configuration Structure

```
init.lua                          # Main entry point - all core config and plugin loading
lua/
  kickstart/
    plugins/                      # Modular plugin configurations
      lspconfig/
        lspconfig.lua            # LSP setup with Mason integration
        servers.lua              # LSP server configurations
      telescope.lua              # Fuzzy finder configuration
      cmp.lua                    # Autocompletion setup (custom config with reduced autocomplete)
      neo-tree.lua               # File explorer
      gitsigns.lua               # Git integration
      harpoon.lua                # File navigation
      fugitive.lua               # Git commands
      undotree.lua               # Undo history visualization
  custom/
    plugins/
      init.lua                   # Add custom plugins here
```

### Plugin Loading Pattern

Plugins are loaded via `lazy.setup()` in `init.lua`. Each plugin can be:
1. Inline configuration in `init.lua` (e.g., gitsigns, conform.nvim)
2. External module via `require` (e.g., `require 'kickstart.plugins.telescope'`)

Each plugin module returns a table with the plugin spec for lazy.nvim.

### Key Architectural Decisions

**Single vs Modular Config**: The base is single-file (`init.lua`) but extends functionality through modular plugin files in `lua/kickstart/plugins/`. This balances kickstart's teaching approach with maintainability.

**LSP Setup**: Uses Mason for automatic LSP installation. LSP servers are defined in `lua/kickstart/plugins/lspconfig/servers.lua`. The config handles both common servers (lua_ls, gopls, html, etc.) and has conditional setup for Linux-specific servers (ruby_lsp, rubocop).

**Autocompletion Customization**: The cmp.lua configuration has been customized to reduce aggressive autocomplete behavior:
- Manual trigger with `<C-Space>`
- Tab/Enter behavior modified to be less intrusive
- Autocomplete triggers after 2 characters with debouncing (200ms)

**Formatting**: Uses conform.nvim with format-on-save for most filetypes. C/C++ are excluded from auto-format. Currently only StyLua is configured for Lua files.

**TypeScript**: Uses `typescript-tools.nvim` instead of the default ts_ls for enhanced TypeScript support.

**Colorscheme**: kanagawa-wave theme is set as the default.

### LSP Key Bindings (Active when LSP attached)

- `gd` - Go to definition (Telescope)
- `gr` - Go to references (Telescope)
- `gI` - Go to implementation (Telescope)
- `gD` - Go to declaration
- `<leader>D` - Type definition (Telescope)
- `<leader>ds` - Document symbols (Telescope)
- `<leader>ws` - Workspace symbols (Telescope)
- `<leader>rn` - Rename symbol
- `<leader>ca` - Code action
- `<leader>th` - Toggle inlay hints
- `<leader>f` - Format buffer

### Telescope Key Bindings

- `<leader>sf` - Search files
- `<C-p>` - Search git files
- `<leader>sg` - Live grep
- `<leader>sw` - Search current word
- `<leader>sh` - Search help
- `<leader>sd` - Search diagnostics
- `<leader>sr` - Resume last search
- `<leader><leader>` - Find buffers
- `<leader>/` - Fuzzy find in current buffer

### Custom Settings in init.lua

- Leader key: `<Space>`
- Relative line numbers enabled
- Clipboard synced with OS (`unnamedplus`)
- Tab width: 2 spaces
- Undo file enabled for persistent undo history
- Custom keymaps:
  - `<leader>n` / `<leader>N` - Navigate quickfix list
  - `<leader>td` - Open TodoTelescope

## Adding New Plugins

To add a new plugin:

1. **For one-off plugins**: Add directly to the `lazy.setup()` table in `init.lua`
2. **For custom modular plugins**: Create a file in `lua/custom/plugins/` that returns a lazy.nvim plugin spec
3. **For LSP servers**: Add to the `servers` table in `lua/kickstart/plugins/lspconfig/servers.lua`

## Important Notes

- This config targets Neovim stable and nightly versions only
- Nerd Font support is enabled (`vim.g.have_nerd_font = true`)
- Window navigation keybinds (C-h/j/k/l) are commented out in init.lua
- Clipboard sync is immediate, not scheduled on UiEnter
- The config includes the claude-code.nvim plugin for AI-assisted development
