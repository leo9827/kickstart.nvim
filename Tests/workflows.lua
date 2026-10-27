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

local function test_return_tickets()
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
end

local function test_context_copy()
  -- Exact visual text, Unicode, Markdown fences, and diagnostics in the copy.
  local buf = new({ 'αβ ``` tail', 'second line', 'third line' }, dir .. '/pkg/context.lua')
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
end

local function test_copy_history()
  local ticket = require 'custom.return_ticket'
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
end

local function test_checkpoints()
  -- Checkpoints retain unsaved baseline and comparison buffers cannot modify sources.
  local checkpoint = require 'custom.checkpoint'
  local buf = new({ 'already uncommitted', 'keep' }, dir .. '/checkpoint.txt')
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
end

local function test_search_scope()
  -- Scope changes feed the existing picker without changing the editor directory.
  local scope = require 'custom.search_scope'
  vim.fn.writefile({ 'search needle' }, dir .. '/pkg/search.txt')
  new({ 'search needle' }, dir .. '/pkg/search.txt')
  local builtin = require 'telescope.builtin'
  local originals, calls = {}, {}
  for _, method in ipairs { 'find_files', 'live_grep', 'grep_string', 'buffers' } do
    originals[method] = builtin[method]
    builtin[method] = function(opts)
      calls[#calls + 1] = { method, opts }
    end
  end
  local cwd = vim.fn.getcwd()
  scope.search 'find_files'
  eq(calls[#calls][2].cwd, dir, 'project search root')
  vim.ui.select = function(items, _, callback)
    callback(items[2])
  end
  scope.choose()
  scope.search 'live_grep'
  eq(calls[#calls][2].cwd, dir .. '/pkg', 'folder search root')
  vim.ui.select = function(items, _, callback)
    callback(items[3])
  end
  scope.choose()
  scope.search 'find_files'
  eq(calls[#calls][1], 'buffers', 'open buffer files scope')
  scope.search 'grep_string'
  eq(calls[#calls][2].search_dirs, { dir .. '/pkg/search.txt' }, 'open file search excludes unnamed / unsaved buffers')
  eq(vim.fn.getcwd(), cwd, 'scope does not change cwd')
  for method, original in pairs(originals) do
    builtin[method] = original
  end
  -- Exercise the actual picker and inspect its results, not just option routing.
  vim.ui.select = function(items, _, callback)
    callback(items[2])
  end
  scope.choose()
  scope.search 'find_files'
  local prompt = api.nvim_get_current_buf()
  local picker = require('telescope.actions.state').get_current_picker(prompt)
  check(
    vim.wait(3000, function()
      return picker.manager and picker.manager:num_results() > 0
    end),
    'real scoped picker results'
  )
  for entry in picker.manager:iter() do
    check(entry.value == 'search.txt', 'folder picker leaked files outside scope')
  end
  require('telescope.actions').close(prompt)
  keys '<Esc>'
  vim.ui.select = select
end

local function test_bookmark_preservation()
  -- J and =ap keep user bookmarks; count joining and cursor placement still work.
  local buf = new { 'one', 'two', 'three', '', 'four' }
  api.nvim_buf_set_mark(buf, 'z', 5, 0, {})
  api.nvim_buf_set_mark(buf, 'a', 5, 0, {})
  keys 'gg03J'
  eq(lines()[1], 'one two three', 'counted join')
  eq(api.nvim_buf_get_mark(buf, 'z'), { 3, 0 }, 'join preserves z bookmark')
  keys '=ap'
  eq(api.nvim_buf_get_mark(buf, 'a'), { 3, 0 }, 'indent preserves a bookmark')
end

local function test_go_tests()
  -- Real Go processes: pass, fail location, nearest selection, rerun, stale results,
  -- compilation error, unsaved guard and cancellation of the spawned test binary.
  local go = require 'custom.go_tests'
  vim.fn.writefile({ 'module workflow.test', '', 'go 1.22' }, dir .. '/go.mod')
  local source = {
    'package workflow',
    'import ("testing"; "time"; "os")',
    'func TestPass(t *testing.T) { t.Log("ok") }',
    'func TestFail(t *testing.T) { t.Fatal("expected failure") }',
    'func TestSlow(t *testing.T) { time.Sleep(3*time.Second); os.WriteFile("orphan", []byte("bad"), 0600) }',
  }
  local path = dir .. '/pkg/workflow_test.go'
  vim.fn.writefile(source, path)
  vim.cmd.edit { args = { path }, bang = true }
  vim.b.autoformat_disabled = true
  local buf = api.nvim_get_current_buf()
  vim.treesitter.start(buf, 'go')
  vim.treesitter.get_parser(buf):parse()
  local function finish()
    check(
      vim.wait(60000, function()
        return not go.status():find('running', 1, true)
      end, 20),
      'Go test timeout'
    )
  end
  local function go_at(row)
    api.nvim_set_current_buf(buf)
    api.nvim_win_set_cursor(0, { row, 25 })
    go.run 'nearest'
    finish()
  end
  vim.wait(150, function()
    return false
  end)
  local win = api.nvim_get_current_win()
  go_at(3)
  check(go.status():find('pass', 1, true), 'real passing test')
  eq(api.nvim_get_current_win(), win, 'test completion does not steal focus')
  vim.fn.mkdir(dir .. '/other', 'p')
  local other_path = dir .. '/other/broken_test.go'
  vim.fn.writefile({ 'package other', 'import "testing"', 'func TestBroken(t *testing.T) { t.Fatal("broken") }' }, other_path)
  vim.cmd.edit { args = { other_path }, bang = true }
  eq(go.status(), '', 'untested package must not inherit passing result')
  go.output()
  check(table.concat(lines(), '\n'):find('TEST pass', 1, true), 'output keeps last result outside tested package')
  keys 'q'
  api.nvim_set_current_buf(buf)
  eq(go.status(), 'TEST pass', 'returning to tested package shows result')
  api.nvim_buf_set_lines(buf, 2, 3, false, { 'func TestRenamed(t *testing.T) { t.Log("ok") }' })
  vim.cmd.write()
  go.rerun()
  finish()
  eq(go.status(), 'TEST no matching tests', 'renamed test must not report pass')
  check(messages[#messages]:find('no matching tests', 1, true), 'missing test notification')
  go_at(3)
  eq(go.status(), 'TEST pass', 'running renamed test explicitly recovers')
  go_at(4)
  check(go.status():find('FAIL', 1, true), 'real failing test')
  go.failures()
  local failures = vim.fn.getqflist()
  check(#failures > 0 and failures[1].lnum == 4 and api.nvim_buf_get_name(failures[1].bufnr) == path, 'failure resolves exact file and line')
  vim.cmd.cclose()
  api.nvim_set_current_buf(buf)
  api.nvim_buf_set_lines(buf, 3, 4, false, { 'func TestFail(t *testing.T) { t.Log("fixed") }' })
  api.nvim_exec_autocmds('TextChanged', { buffer = buf })
  check(go.status():find('stale', 1, true), 'editing marks result stale')
  go.rerun()
  check(messages[#messages]:find('Save Go changes', 1, true), 'unsaved changes do not run old code')
  vim.cmd.write()
  go.rerun()
  finish()
  check(go.status() == 'TEST pass', 'rerun uses saved code and clears stale marker')
  api.nvim_buf_set_lines(buf, -1, -1, false, { 'func broken(' })
  vim.cmd.write()
  go.run 'package'
  finish()
  check(go.status():find('FAIL', 1, true), 'compilation failure status')
  go.failures()
  check(#vim.fn.getqflist() > 0, 'compilation failure locations')
  vim.cmd.cclose()
  api.nvim_set_current_buf(buf)
  api.nvim_buf_set_lines(buf, -2, -1, false, {})
  vim.cmd.write()
  api.nvim_win_set_cursor(0, { 5, 25 })
  vim.treesitter.get_parser(buf):parse()
  go.run 'nearest'
  check(go.status():find('running', 1, true), 'slow test started')
  vim.wait(1000, function()
    return false
  end)
  go.cancel()
  finish()
  check(go.status():find('cancelled', 1, true), 'cancel status')
  vim.wait(3200, function()
    return false
  end)
  check(vim.fn.filereadable(dir .. '/pkg/orphan') == 0, 'cancel leaves no orphan test subprocess')
  go.output()
  check(not vim.bo.modifiable and vim.bo.buftype == 'nofile', 'test output is read-only')
  keys 'q'

  -- A package without tests and a skipped test must not be advertised as passing.
  vim.fn.mkdir(dir .. '/empty', 'p')
  local empty_path = dir .. '/empty/empty.go'
  vim.fn.writefile({ 'package empty' }, empty_path)
  vim.cmd.edit { args = { empty_path }, bang = true }
  go.run 'package'
  finish()
  eq(go.status(), 'TEST no tests', 'package without tests is explicit')
  vim.fn.writefile({ 'package empty', 'import "testing"', 'func TestSkipped(t *testing.T) { t.Skip("intentional") }' }, dir .. '/empty/empty_test.go')
  go.run 'package'
  finish()
  eq(go.status(), 'TEST skipped', 'skipped tests are distinguished from passes')
end

test_return_tickets()
test_context_copy()
test_copy_history()
test_checkpoints()
test_search_scope()
test_bookmark_preservation()
test_go_tests()

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
