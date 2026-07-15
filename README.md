# Neovim configuration

Personal Neovim configuration based on Kickstart, targeting Neovim 0.12.

## External dependencies

- `git`, `make`, `rg`, `fd`, `lazygit`
- a C compiler and a Nerd Font
- Mise for language runtimes and development tools

Language servers, formatters, linters, and debug adapters are declared globally in
`~/.config/mise/config.toml` and resolved through Mise shims.

## Layout

- `init.lua`: editor defaults and shared plugin configuration
- `lua/custom/keymaps.lua`: plugin-independent mappings
- `lua/custom/plugins/`: feature-oriented plugin specifications
- `lua/kickstart/plugins/`: retained Kickstart plugin specifications
- `ftplugin/`: filetype-local behavior

## Maintenance

- `:Lazy` — plugins
- `mise install` — install declared language tools
- `mise ls --current` — inspect active tool versions
- `make check` — format, startup, LSP, DAP, and diff checks
- `:Telescope keymaps` — active mappings
- `:checkhealth` — diagnostics
