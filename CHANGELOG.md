# Changelog

## v1.0.0 — 2026-10-28

First tagged release of my Neovim configuration. This records the recent editing
and navigation improvements as a baseline for future versions. Built for Neovim
0.12; see the [README](README.md) for setup and shortcuts.

### Editing and navigation

- Save a return ticket before exploring code, then restore the original window,
  cursor position, and scroll position. The bookmark follows edits above it.
- Copy code with its source path, line range, and optional diagnostics. Browse
  recent yanks and cycle through them after pasting.
- Capture an editing checkpoint, including unsaved changes, and compare it with
  the current buffer in a separate diff tab.
- Switch file and text searches between the project, current folder, and open
  files.
- See search counts in the statusline and a brief highlight at jump destinations.
- Highlight external file changes and compare the snapshots around a reload.
- Toggle format-on-save per buffer and report formatting failures without
  repeating the same notification.
- Reduce expensive editor features automatically for large files, with a manual
  override for the current buffer.

### Go tests

- Run the nearest test or current package, rerun the previous target, and cancel
  a running test together with its subprocess.
- Browse captured output and jump to failures. Show results in the tested
  package's statusline and mark them stale after relevant buffer changes.

### Fixes and maintenance

- Scroll one line per mouse-wheel event for finer mouse and touchpad control.
- Preserve bookmarks when joining or indenting text and cycling pasted copies.
- Include errors in diagnostic severity filters and fix Tree-sitter tool and
  parser compatibility.
- Simplify Lua helpers and plugin settings, shorten comments, and reorganize
  configuration and workflow checks into readable test cases.
- Format staged Lua automatically before commits while preserving unstaged
  edits. Enable the tracked hook once per clone with `make install-hooks`.
- Add regression checks for editing workflows, Go tests, and the commit hook;
  `make check` also checks Lua formatting across the configuration.
