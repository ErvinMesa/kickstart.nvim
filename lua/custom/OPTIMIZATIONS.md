# Neovim Performance Optimizations

This directory contains optimized configurations for better responsiveness and performance, especially when using neotree and other heavy plugins.

## Key Optimizations

### 1. Neo-Tree (`neo-tree.lua`)
- **Lazy loading**: Only loads on command (`:Neotree`) or keypress
- **Shallow scanning**: Uses `scan_mode = 'shallow'` to avoid deep file system traversal
- **Smart filtering**: Respects `.gitignore` and hides common directories (node_modules, dist, etc.)
- **Libuv watcher**: Uses native file watching for better responsiveness
- **Reduced autocomplete**: `follow_current_file = false` to avoid constant updates
- **Tab-friendly**: Source selector with keyboard navigation

### 2. Telescope (`telescope.lua`)
- **Smart result caching**: Picker results are cached for faster re-searches
- **Optimized searching**: Uses ripgrep with smart caching and reduced result limits (50 max)
- **Excluded patterns**: Filters out node_modules, .git, and other build directories
- **Responsive UI**: Horizontal layout with truncated preview for speed
- **Smart previewers**: Disables treesitter highlighting in preview to improve responsiveness

### 3. Treesitter (`treesitter.lua`)
- **Large file handling**: Disables highlighting for files > 500KB
- **Lazy loading**: Only loads on `BufReadPost` and `BufNewFile`
- **Reduced parsers**: Only installs essential parsers by default
- **No auto-install**: Prevents unnecessary parser installations
- **Incremental selection**: Enabled for better text object experience

### 4. Completion (cmp.lua)
- **Smart debouncing**: 200ms debounce prevents excessive triggers
- **Reduced sources**: Only uses LSP, snippets, buffer, and path sources
- **Limited view**: Max 50 completion items visible at once
- **Throttled updates**: 100ms throttle for smoother UX
- **Event-based loading**: Only loads on `InsertEnter` to save startup time

### 5. Init.lua Settings
- **Lazyredraw**: Reduces redraw overhead for faster rendering
- **Synmaxcol limit**: Limits syntax highlighting columns to 300 for large lines
- **TTY optimization**: Enables fast terminal rendering
- **Updated timing**: 250ms update time for responsive cursor operations

### 6. Plugin Loading Strategy
- **Lazy loading**: Most plugins now use `cmd`, `keys`, `event` triggers
- **On-demand loading**: Gitsigns, undotree, harpoon, and fugitive load only when needed
- **Optimized defaults**: Removed aggressive auto-loading configurations

## Files Organization

```
lua/custom/
├── plugins/
│   ├── init.lua          # Exports optimized plugins
│   ├── neo-tree.lua      # Optimized file browser
│   ├── telescope.lua     # Optimized fuzzy finder
│   ├── treesitter.lua    # Optimized syntax highlighting
│   └── cmp.lua           # Optimized completion
└── OPTIMIZATIONS.md      # This file
```

## Usage

The optimizations are automatically loaded via `lua/custom/plugins/init.lua` which is imported in your main `init.lua`. No additional configuration is needed.

## Recommended Settings

For best performance on slower systems:
1. Disable LSP diagnostics with `:LspInfo` and `:LspStop`
2. Use shallow git ignore patterns in .gitignore
3. Exclude large directories from your project
4. Consider disabling inlay hints with `<leader>th`

## Performance Tips

- **Startup**: Run `:Lazy` and check for plugins not yet loaded
- **Runtime**: Use `:LspInfo` to check active language servers
- **Large files**: Consider disabling features for files > 1MB
- **Git**: Keep .git excluded from file searches via .gitignore

## Customization

To adjust performance further:
1. Increase `vim.o.updatetime` for even less frequent updates
2. Modify `scan_mode` in neo-tree to 'normal' for more thorough scans
3. Adjust `keyword_length` in cmp to 3+ to reduce trigger frequency
4. Change `max_view_entries` in cmp to see fewer suggestions

## Debugging

If performance is still slow:
1. Check `:Lazy` for all loaded plugins
2. Run `:LspInfo` to see active language servers
3. Use `:checkhealth` to identify potential issues
4. Profile startup time with `nvim --startuptime startup.log`
