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

-- Exact visual text, Unicode, Markdown fences, and diagnostics in the copy.
buf = new({ 'αβ ``` tail', 'second line', 'third line' }, dir .. '/pkg/context.lua')
vim.bo.filetype = 'lua'
local ns = api.nvim_create_namespace 'workflow-diagnostics'
vim.diagnostic.set(ns, buf, {
  { lnum = 0, col = 0, message = 'relevant error', severity = vim.diagnostic.severity.ERROR },
  { lnum = 2, col = 0, message = 'unrelated error', severity = vim.diagnostic.severity.ERROR },
})
keys 'gg0v7l'
require('custom.context_copy').copy(true)
local copied = vim.fn.getreg '+'
check(copied:find('pkg/context.lua:1-1', 1, true), 'relative copy source')
check(copied:find('````lua', 1, true), 'embedded Markdown fence escaped')
check(copied:find('αβ', 1, true), 'Unicode copy')
check(copied:find('relevant error', 1, true) and not copied:find('unrelated error', 1, true), 'copy diagnostic range')
keys '<Esc>'
vim.diagnostic.reset(ns)

-- Exclusive selections use the actual copied lines in both source and diagnostics.
local selection = vim.o.selection
vim.o.selection = 'exclusive'
vim.diagnostic.set(ns, buf, {
  { lnum = 1, col = 0, message = 'excluded second line', severity = vim.diagnostic.severity.ERROR },
})
for _, motion in ipairs { 'gg0vj0', 'gg0jvkg0' } do
  keys(motion)
  require('custom.context_copy').copy(true)
  copied = vim.fn.getreg '+'
  check(copied:find('pkg/context.lua:1-1', 1, true), 'exclusive selection source range')
  check(not copied:find('excluded second line', 1, true), 'exclusive selection excludes endpoint diagnostics')
  keys '<Esc>'
end
vim.o.selection = selection
vim.diagnostic.reset(ns)

-- Copy history records yanks, not deletes; supports character, line and block puts.
local history = require 'custom.yank_history'
history.clear()
new { 'alpha', 'beta', 'gone' }
keys 'ggyyj0yw' -- beta is charwise, alpha is linewise.
keys 'jdd'
new { 'target' }
api.nvim_win_set_cursor(0, { 1, 0 })
local register = vim.fn.getreg '"'
history.paste()
eq(lines(), { 'tbetaarget' }, 'latest yank pasted (delete excluded)')
history.cycle(1)
eq(lines(), { 'target', 'alpha' }, 'cycle to linewise copy')
eq(vim.fn.getreg '"', register, 'paste preserves unnamed register')
vim.cmd.undo()
eq(lines(), { 'tbetaarget' }, 'cycle is independently undoable')
api.nvim_buf_set_lines(0, 0, 1, false, { 'user edit' })
history.cycle(1)
eq(lines(), { 'user edit' }, 'cycle refuses intervening edit')
history.clear()
new { 'ABxx', 'CDyy' }
keys 'gg0<C-v>jly'
new { '123', '456' }
history.paste()
eq(lines(), { '1AB23', '4CD56' }, 'blockwise copy preserves shape')
-- Mixing multiline, block and linewise copies must restore the entire original slice.
new { 'last line' }
keys 'ggyy'
new { 'end' }
history.paste()
eq(lines(), { 'end', 'last line' }, 'linewise EOF paste')
history.cycle(1)
eq(lines(), { 'eABnd', ' CD' }, 'blockwise cycling extends EOF')
history.cycle(1)
eq(lines(), { 'end', 'last line' }, 'cycle removes extra block lines')
vim.cmd.undo()
eq(lines(), { 'eABnd', ' CD' }, 'block cycle undo')
vim.cmd.redo()
eq(lines(), { 'end', 'last line' }, 'block cycle redo')
history.clear()

-- Cycling must preserve a return ticket anchored in surviving original text.
new { 'AAA', 'longer' }
keys 'gg0ywj0yw'
new { 'original text', 'second line' }
api.nvim_win_set_cursor(0, { 1, 9 })
ticket.save()
api.nvim_win_set_cursor(0, { 1, 0 })
history.paste()
ticket.restore()
eq(api.nvim_win_get_cursor(0), { 1, 15 }, 'ticket follows first paste')
history.cycle(1)
ticket.restore()
eq(api.nvim_win_get_cursor(0), { 1, 12 }, 'ticket survives cycling to shorter copy')
history.cycle(-1)
ticket.restore()
eq(api.nvim_win_get_cursor(0), { 1, 15 }, 'ticket survives cycling back')
vim.cmd.undo()
ticket.restore()
eq(api.nvim_win_get_cursor(0), { 1, 12 }, 'ticket survives cycle undo')
history.clear()

-- Compare cycling with native puts across multiline, Unicode, tab and EOF cases.
local copies = {}
for _, copy in ipairs {
  { { 'one', 'two' }, 'ggVjy' },
  { { 'aβ', '中z' }, 'gg0vjly' },
  { { 'XY', 'ZW' }, 'gg0<C-v>jly' },
} do
  new(copy[1])
  keys(copy[2])
  table.insert(copies, 1, { lines = vim.fn.getreg('"', 1, true), kind = vim.fn.getregtype '"' })
end
for _, case in ipairs {
  { { '' }, { 1, 0 } },
  { { 'tail' }, { 1, 3 } },
  { { 'αβγ', 'next' }, { 1, 2 } },
  { { 'x\tend', '\tx' }, { 1, 0 } },
  { { 'long line', 'x', 'last' }, { 1, 5 } },
} do
  new(case[1])
  api.nvim_win_set_cursor(0, case[2])
  history.paste()
  for index, copy in ipairs(copies) do
    if index > 1 then
      history.cycle(1)
    end
    local expected = api.nvim_create_buf(false, true)
    api.nvim_buf_set_lines(expected, 0, -1, false, case[1])
    api.nvim_buf_call(expected, function()
      api.nvim_win_set_cursor(0, case[2])
      api.nvim_put(copy.lines, copy.kind, true, true)
    end)
    eq(lines(), api.nvim_buf_get_lines(expected, 0, -1, false), 'cycle matches native put for ' .. vim.inspect(case))
    api.nvim_buf_delete(expected, { force = true })
  end
end
history.clear()

-- Checkpoints retain unsaved baseline and comparison buffers cannot modify sources.
local checkpoint = require 'custom.checkpoint'
buf = new({ 'already uncommitted', 'keep' }, dir .. '/checkpoint.txt')
checkpoint.save()
api.nvim_buf_set_lines(buf, 0, 1, false, { 'experiment' })
vim.ui.select = function(items, _, callback)
  callback(items[1])
end
checkpoint.save() -- Default keeps the original checkpoint.
checkpoint.review()
local snapshots = {}
for _, win in ipairs(api.nvim_tabpage_list_wins(0)) do
  local snapshot = api.nvim_win_get_buf(win)
  check(not vim.bo[snapshot].modifiable and vim.bo[snapshot].buftype == 'nofile', 'checkpoint is read-only')
  snapshots[#snapshots + 1] = api.nvim_buf_get_lines(snapshot, 0, 1, false)[1]
end
check(vim.tbl_contains(snapshots, 'already uncommitted') and vim.tbl_contains(snapshots, 'experiment'), 'checkpoint retains dirty baseline')
keys 'q'
eq(api.nvim_buf_get_lines(buf, 0, -1, false), { 'experiment', 'keep' }, 'review leaves source intact')
api.nvim_set_current_buf(buf)
checkpoint.clear()
checkpoint.review()
check(messages[#messages]:find('No checkpoints', 1, true), 'checkpoint clearing')

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
