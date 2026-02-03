-- Minimal Neovim init for avante-lite.nvim tests.
-- Run from repo root:
--   XDG_DATA_HOME=/tmp/nvim-data XDG_STATE_HOME=/tmp/nvim-state XDG_CACHE_HOME=/tmp/nvim-cache \
--     nvim --headless -u local/avante-lite.nvim/tests/minimal_init.lua

vim.o.swapfile = false
vim.o.writebackup = false
vim.o.undofile = false
vim.o.shadafile = "NONE"

local this_file = debug.getinfo(1, "S").source:sub(2)
local plugin_root = vim.fn.fnamemodify(this_file, ":p:h:h")

vim.opt.runtimepath:prepend(plugin_root)

dofile(plugin_root .. "/tests/run.lua")

