# Neovim configuration

My Neovim setup, based on Kickstart and built for Neovim 0.12.

## Setup and maintenance

You'll need `git`, `make`, `rg`, `fd`, `lazygit`, a C compiler, a Nerd Font,
and Mise. Language tools live in `~/.config/mise/config.toml`; `mise.toml`
lists the tools for this project. Nvim finds them through Mise shims.

| Command              | Purpose                                  |
| -------------------- | ---------------------------------------- |
| `mise install`       | Install declared tools                   |
| `mise ls --current`  | Inspect active tool versions             |
| `:Lazy`              | Manage plugins                           |
| `:checkhealth`       | Diagnose configuration and tool problems |
| `:Telescope keymaps` | Find active shortcuts                    |
| `make check`         | Run all formatting and regression checks |

## Configuration layout

- `init.lua`: editor defaults and shared plugin settings.
- `lua/custom/keymaps.lua`: shared shortcuts and setup for the custom workflows.
- `lua/custom/`: editing helpers, feedback, and themes.
- `lua/custom/plugins/`: plugin settings, grouped by feature.
- `lua/kickstart/plugins/`: plugin settings kept from Kickstart.
- `ftplugin/`: settings and helpers for individual filetypes.

## Editing feedback

Search counts appear in the statusline while search highlighting is active.
Search, diagnostic, picker, Git, and cross-file jumps briefly highlight the
destination.

### Formatting

- `Space t F`: pause or resume automatic formatting for this file (`FMT OFF`).
- `Space f`: format manually, even when automatic formatting is paused.
- `:ConformInfo`: inspect formatters and errors.

If formatting fails, you'll get one notification. The same error stays quiet
until the formatter recovers or reports a different problem.

### External file changes

When a file changes outside Nvim, the changed lines briefly light up. Use
`Space w e` to compare the latest versions before and after the reload in a
separate tab, and `q` to close it. Edits you make after the reload won't appear
in that comparison. If the file has conflicting unsaved edits, Nvim asks what
to do as usual.

This captures snapshots only for files below 1 MiB with light mode off.

### Large files

Opening or saving a file turns on `LIGHT` mode if it meets any of these limits:

- At least 1 MiB in size.
- At least 20,000 lines.
- A line at least 2,000 bytes long.

Light mode cuts back on highlighting, folding, analysis, completion, and
decorations. It also skips automatic formatting. Use `Space t l` to turn it on
or off for the current file. That choice lasts until you wipe the buffer.

## Navigation and search

### Return tickets

Press `Space m b` before following a trail through the code. When you're ready
to return, `Space m r` brings back the original window and view. The saved
position follows any edits above it. You get one ticket per tab.

### Search scope

Use `Space s S` to choose where to search: the project, the current file's
folder, or open files. That choice applies to `Space s f` (files),
`Space s g` (grep), and `Space s w` (current word).

Search starts at the project root by default. Choosing another scope leaves
the working directory alone. In the open-files scope, grep searches saved
contents on disk.

## Copy and paste

### Copy with context

- `Space c y`: copy the selection, or current line, with its path and line range.
- `Space c Y`: also include diagnostics in that range.

Both shortcuts put a Markdown excerpt in the clipboard.

### Copy history

| Keys        | Action                                        |
| ----------- | --------------------------------------------- |
| `Space p`   | Paste the latest explicit copy in normal mode |
| `]y` / `[y` | Replace that paste with an older / newer copy |
| `Space s y` | Choose a copy by source and preview           |
| `Space c X` | Clear copy history                            |

After pasting, you can cycle through older copies until you edit again or undo.
Each replacement can be undone, and bookmarks in the surrounding text stay put.
Native `p` / `P` and visual-mode `Space p` work as before.

History keeps the last 30 explicit yanks, up to 100 KiB each. Deleting text or
changing the clipboard outside Nvim won't add an entry.

## Editing checkpoints

- `Space w c`: capture the current file, including unsaved edits.
- `Space w v`: choose a checkpoint and compare it with current edits.
- `Space w C`: clear this file's checkpoint.

The comparison opens read-only snapshots in a separate tab; press `q` to close
it. To overwrite an existing checkpoint, choose "Replace checkpoint".

You can keep one checkpoint per buffer, for up to 20 files below 1 MiB each.
Wiping a buffer clears its checkpoint.

## Go tests

| Keys        | Action                                                  |
| ----------- | ------------------------------------------------------- |
| `Space T n` | Run the enclosing test function, including its subtests |
| `Space T p` | Run the current package                                 |
| `Space T r` | Rerun the previous test target                          |
| `Space T k` | Cancel the running test and its subprocess              |
| `Space T f` | Open failure locations                                  |
| `Space T o` | Open captured output; `q` closes it                     |

Save modified Go files in the module before running tests: they use the code
on disk. The statusline shows results only in the package you tested, with
separate states for passing, skipped, and missing tests. You'll get one
notification when the run finishes.

If you edit or reload a relevant buffer, the result is marked stale. Changes
outside Nvim go unnoticed when the file isn't loaded. The output keeps the
latest 2,000 lines, and test execution has a two-minute timeout.

Return tickets, copy history, checkpoints, and test results last only until
you close Nvim.

## Checks

Run `make check` for the full suite, including StyLua and Git whitespace checks.
You can also run each group on its own:

| Target                  | Coverage                                                    |
| ----------------------- | ----------------------------------------------------------- |
| `make check-config`     | Startup, tools, mappings, LSP, DAP, parsers, and folding    |
| `make check-experience` | Diagnostics, formatting, external changes, and navigation   |
| `make check-workflows`  | Tickets, copies, checkpoints, search, and real Go test runs |
| `make check-theme`      | Terminal-driven light/dark themes and plugin surfaces       |

The cases in `Tests/config.lua` each run in a fresh Nvim process.
`Tests/config_preload.lua` sets up the test for asynchronous parser installation.
