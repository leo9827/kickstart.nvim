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

## Editing feedback

- Search progress appears in the statusline while search highlighting is active.
- `Space t F` pauses/resumes automatic formatting for the current file (`FMT OFF`).
  Manual formatting with `Space f` still works. Failures notify once until the
  formatter recovers or the error changes; `:ConformInfo` shows details.
- External file updates briefly highlight changed lines. `Space w e` opens the
  latest before/after snapshots in a separate diff tab; `q` closes it. Snapshots
  exclude later edits and are kept only for files below 1 MiB outside light mode.
  Unsaved conflicts retain Neovim's normal confirmation behavior.
- Search, diagnostic, picker, Git, and cross-file jumps briefly highlight the
  destination.
- Files at least 1 MiB, 20,000 lines, or with a line at least 2,000 bytes enter
  `LIGHT` mode when opened or saved. This reduces highlighting, folding, analysis,
  completion, and decorations, and skips automatic formatting. `Space t l`
  toggles it for the current file; the override lasts until the buffer is wiped.

Run `make check-experience` for the feedback and file-update regression checks.

## Editing workflows

| Keys | Action |
| --- | --- |
| `Space m b` / `Space m r` | Save / return to a ticket in this tab. Restores the original window and view; the position follows edits above it. |
| `Space c y` / `Space c Y` | Copy the selected text (or current line) with file path and line range; uppercase `Y` also includes diagnostics in that range. |

Tickets are kept only in this Nvim process.

Context copy writes only to the clipboard.

Run `make check-workflows` for the workflow regression checks.
