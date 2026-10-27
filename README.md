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
| `Space p` | Paste the latest explicit copy in normal mode. Visual-mode `Space p` keeps its existing behavior. |
| `]y` / `[y` | Replace that paste with an older / newer copy. Stops after another edit or undo; each replacement is undoable. |
| `Space s y` / `Space c X` | Choose a copy by source and preview / clear copy history. |
| `Space w c` / `Space w v` / `Space w C` | Capture this file's checkpoint / choose a checkpoint to compare / clear this file's checkpoint. |
| `Space s S` | Choose project, current file's folder, or open files for `Space s f`, `Space s g`, and `Space s w`. |
| `Space T n` / `Space T p` | Run the enclosing Go test function / current package. |
| `Space T r` / `Space T k` | Rerun the previous Go test / cancel the running test and its subprocess. |
| `Space T f` / `Space T o` | Open failure locations / captured test output. |

Tickets, copy history, checkpoints, and test results are kept only in this Nvim
process. Copy history records the last 30 explicit yanks up to 100 KiB each;
deletes and external clipboard changes are excluded. Native `p` / `P` are unchanged.
Context copy writes only to the clipboard. Checkpoints include unsaved edits,
keep one baseline per buffer (up to 20 files below 1 MiB each), and compare
read-only snapshots; `q` closes the comparison. Wiping a buffer clears its checkpoint.

Search scope starts at the project root and never changes the working directory.
Open-file grep searches saved files on disk. Go tests also run saved code: save
modified Go files in that module first. Nearest-test execution includes subtests
of the enclosing function. Results appear only in the tested package's statusline,
distinguish missing or skipped tests from passes, and become stale after relevant
buffer edits or reloads. Completion produces one notification. Test output
keeps the latest 2,000 lines; `q` closes the output window. Tests time out after
two minutes. External changes to files not loaded in Nvim are not tracked.

Run `make check-workflows` for the workflow regression checks, including real Go
pass/fail, rerun, compilation failure, and cancellation cases.
