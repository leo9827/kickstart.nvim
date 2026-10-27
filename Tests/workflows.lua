local api = vim.api
local notify, select = vim.notify, vim.ui.select
local messages = {}
vim.notify = function(message)
  messages[#messages + 1] = tostring(message)
end
vim.wait(100, function()
  return false
end)
vim.o.clipboard = ''
local clipboard = {}
vim.g.clipboard = {
  name = 'workflow-test',
  copy = {
    ['+'] = function(lines, kind)
      clipboard = { lines, kind }
    end,
    ['*'] = function() end,
  },
  paste = {
    ['+'] = function()
      return clipboard
    end,
    ['*'] = function()
      return { {}, 'v' }
    end,
  },
  cache_enabled = 0,
}
local dir = vim.fn.tempname()
vim.fn.mkdir(dir .. '/pkg', 'p')
dir = vim.uv.fs_realpath(dir)
vim.fn.mkdir(dir .. '/.git', 'p')
local function check(ok, message)
  assert(ok, message .. '\nMessages: ' .. table.concat(messages, '\n'))
end
local function keys(text)
  api.nvim_feedkeys(vim.keycode(text), 'xt', false)
end
local function new(lines, name)
  vim.cmd.enew { bang = true }
  vim.bo.swapfile = false
  if name then
    api.nvim_buf_set_name(0, name)
  end
  api.nvim_buf_set_lines(0, 0, -1, false, lines)
  return api.nvim_get_current_buf()
end
local function lines()
  return api.nvim_buf_get_lines(0, 0, -1, false)
end
local function eq(actual, expected, message)
  check(vim.deep_equal(actual, expected), message .. ': ' .. vim.inspect(actual))
end

-- Return to the original window and view, following edits above the bookmark.
local ticket = require 'custom.return_ticket'
local text = {}
for i = 1, 150 do
  text[i] = 'line ' .. i
end
local buf = new(text)
local original_win = api.nvim_get_current_win()
api.nvim_win_set_cursor(0, { 65, 2 })
vim.fn.winrestview { topline = 60, lnum = 65, col = 2 }
local original_view = vim.fn.winsaveview()
ticket.save()
vim.cmd.vnew()
local other_win = api.nvim_get_current_win()
api.nvim_buf_set_lines(buf, 0, 0, false, { 'inserted' })
ticket.restore()
eq(api.nvim_get_current_win(), original_win, 'return ticket window')
eq(api.nvim_win_get_cursor(0), { 66, 2 }, 'return ticket tracks inserted lines')
eq(vim.fn.winsaveview().topline, original_view.topline + 1, 'return ticket scroll')
api.nvim_set_current_win(other_win)
api.nvim_win_close(original_win, true)
ticket.restore()
eq(api.nvim_get_current_buf(), buf, 'ticket survives closed window')
api.nvim_buf_delete(buf, { force = true })
ticket.restore()
check(messages[#messages]:find('No return ticket', 1, true), 'deleted ticket handled')

vim.ui.select, vim.notify = select, notify
-- Unload fixture buffers before deleting files so deferred checktime cannot reload them.
for _, fixture in ipairs(api.nvim_list_bufs()) do
  if vim.fs.relpath(dir, api.nvim_buf_get_name(fixture)) then
    api.nvim_buf_delete(fixture, { force = true })
  end
end
vim.fn.delete(dir, 'rf')
print 'workflow checks passed'
vim.cmd 'noautocmd qa!'
