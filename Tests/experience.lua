local api = vim.api
local messages = {}
local notify = vim.notify
vim.notify = function(message, level)
  messages[#messages + 1] = { message = tostring(message), level = level }
end
local directory = vim.fn.tempname()
vim.fn.mkdir(directory, 'p')
directory = vim.uv.fs_realpath(directory)
local function check(value, message)
  assert(value, message)
end
local function settle()
  vim.wait(100, function()
    return false
  end, 10)
end
local function new_buffer(lines)
  vim.cmd.enew { bang = true }
  vim.bo.swapfile = false
  api.nvim_buf_set_lines(0, 0, -1, false, lines or { 'one', 'two', 'three' })
  return api.nvim_get_current_buf()
end
local function write(path, lines)
  vim.fn.writefile(lines, path)
end
local function open(path)
  vim.cmd.edit { args = { path }, bang = true }
  settle()
  return api.nvim_get_current_buf()
end
local function marks(bufnr, namespace)
  return api.nvim_buf_get_extmarks(bufnr, api.nvim_create_namespace(namespace), 0, -1, {})
end

require('lazy').load { plugins = { 'nvim-lspconfig', 'conform.nvim', 'lualine.nvim', 'neoscroll.nvim' } }

-- Errors and warnings survive all three severity filters; informational hints do not.
local buf = new_buffer()
local ns = api.nvim_create_namespace 'experience-diagnostics'
vim.diagnostic.set(ns, buf, {
  { lnum = 0, col = 0, severity = vim.diagnostic.severity.ERROR, message = 'test error' },
  { lnum = 1, col = 0, severity = vim.diagnostic.severity.WARN, message = 'test warning' },
  { lnum = 2, col = 0, severity = vim.diagnostic.severity.INFO, message = 'test info' },
})
local float, win = vim.diagnostic.open_float { scope = 'buffer', focusable = false }
local content = table.concat(api.nvim_buf_get_lines(float, 0, -1, false), '\n')
check(content:find 'test error' and content:find 'test warning' and not content:find 'test info', 'diagnostic filtering')
api.nvim_win_close(win, true)
for _, handler in ipairs { 'signs', 'underline' } do
  check(#vim.diagnostic.get(buf, { severity = vim.diagnostic.config()[handler].severity }) == 2, handler .. ' severity filtering')
end
vim.diagnostic.jump { count = 1, pos = { 1, 0 } }
settle()
check(#marks(buf, 'JumpCursorBeacon') > 0, 'short diagnostic jump has no beacon')
vim.diagnostic.reset(ns)

-- Search progress appears during a search and clears with :nohlsearch.
buf = new_buffer { 'needle', 'plain', 'needle' }
vim.fn.setreg('/', 'needle')
vim.o.hlsearch = true
api.nvim_win_set_cursor(0, { 3, 0 })
local component = require 'lualine.components.searchcount' { maxcount = 999, timeout = 20 }
check(component:update_status() == '[2/2]', 'search count missing or wrong')
vim.cmd.nohlsearch()
check(component:update_status() == '', 'search count remains after clearing search')

-- Execute real failing, successful, and timed-out formatter processes.
local conform = require 'conform'
local formatting = require 'custom.formatting'
conform.formatters.experience_fail = { command = '/usr/bin/false' }
conform.formatters.experience_ok = { command = '/bin/cat' }
conform.formatters.experience_slow = { command = '/bin/sleep', args = { '1' } }
conform.formatters_by_ft.experience = { 'experience_ok' }
vim.bo.filetype = 'experience'
local function format(name, timeout)
  local opts, callback = formatting.on_save(buf)
  opts.formatters, opts.timeout_ms, opts.bufnr = { name }, timeout or 500, buf
  conform.format(opts, callback)
  settle()
end
messages = {}
format 'experience_fail'
check(#messages == 1 and messages[1].message:find 'Format failed', 'formatter failure not reported')
format 'experience_fail'
check(#messages == 1, 'repeated format failure spam')
format 'experience_ok'
check(#messages == 1, 'successful formatting is noisy')
format 'experience_fail'
check(#messages == 2, 'new failure after recovery not reported')
format('experience_slow', 20)
check(#messages == 3, 'formatter timeout not reported')
formatting.toggle()
check(formatting.on_save(buf) == nil, 'autoformat toggle did not disable save formatting')
local other = new_buffer()
check(formatting.on_save(other) == nil, 'unconfigured filetypes should save quietly')
vim.bo.filetype = 'experience'
check(formatting.on_save(other) ~= nil, 'autoformat toggle affected another buffer')
api.nvim_set_current_buf(buf)
formatting.toggle()
check(formatting.on_save(buf) ~= nil, 'autoformat did not resume')

-- Real disk reload, including a pre-existing saved edit unrelated to the external change.
local path = directory .. '/external.txt'
write(path, { 'original disk text', 'before', 'unchanged' })
buf = open(path)
api.nvim_buf_set_lines(buf, 0, 1, false, { 'my existing edit' })
vim.cmd.write()
write(path, { 'my existing edit', 'after external update', 'unchanged' })
vim.cmd.checktime()
settle()
check(api.nvim_buf_get_lines(buf, 1, 2, false)[1] == 'after external update', 'external reload failed')
check(#marks(buf, 'ExternalFileChanges') == 1, 'external change highlight wrong')
api.nvim_buf_set_lines(buf, 2, 3, false, { 'later unsaved edit' })
require('custom.external_changes').review()
check(#api.nvim_tabpage_list_wins(0) == 2, 'external diff did not open two panes')
local snapshots = {}
for _, diffwin in ipairs(api.nvim_tabpage_list_wins(0)) do
  check(vim.wo[diffwin].diff, 'review pane is not a diff')
  local diffbuf = api.nvim_win_get_buf(diffwin)
  check(not vim.bo[diffbuf].modifiable, 'review snapshot is editable')
  snapshots[#snapshots + 1] = table.concat(api.nvim_buf_get_lines(diffbuf, 0, -1, false), '\n')
end
local combined = table.concat(snapshots, '\n')
check(combined:find 'before' and combined:find 'after external update', 'review lost before or after version')
check(not combined:find 'later unsaved edit', 'review includes edits made after reload')
vim.cmd.tabclose()
check(vim.bo[buf].modified, 'review altered unsaved state')
check(api.nvim_buf_get_lines(buf, 2, 3, false)[1] == 'later unsaved edit', 'review changed source buffer')
-- Native conflict handling must remain in charge; our plugin installs no FileChangedShell override.
check(#api.nvim_get_autocmds { group = 'external-file-changes', event = 'FileChangedShell' } == 0, 'external reload overrides conflict handling')
local conflict = api.nvim_create_autocmd('FileChangedShell', {
  buffer = buf,
  callback = function()
    vim.v.fcs_choice = 'ignore'
  end,
})
write(path, { 'conflicting disk edit' })
vim.cmd.checktime()
api.nvim_del_autocmd(conflict)
check(api.nvim_buf_get_lines(buf, 2, 3, false)[1] == 'later unsaved edit', 'unsaved text overwritten')

-- The latest refresh replaces the previous review; deletion highlights have a valid anchor.
vim.bo[buf].modified = false
vim.cmd.edit { bang = true }
settle()
write(path, { 'one', 'two', 'three' })
vim.cmd.checktime()
settle()
write(path, { 'one' })
vim.cmd.checktime()
settle()
check(#marks(buf, 'ExternalFileChanges') == 1, 'deletion marker missing')
check(
  vim.wait(2000, function()
    return #marks(buf, 'ExternalFileChanges') == 0
  end, 20),
  'external highlight did not expire'
)

-- Actual Telescope selection highlights the selected location, including a split.
require('lazy').load { plugins = { 'telescope.nvim' } }
vim.fn.setqflist { { filename = path, lnum = 1, col = 1, text = 'target' } }
require('telescope.builtin').quickfix { initial_mode = 'normal' }
settle()
local prompt = api.nvim_get_current_buf()
require('telescope.actions').select_vertical(prompt)
settle()
check(api.nvim_buf_get_name(0) == path, 'Telescope did not select the target')
check(#marks(api.nvim_get_current_buf(), 'JumpCursorBeacon') == 1, 'Telescope selection has no beacon')
vim.cmd.close()

-- Use Gitsigns against a real temporary Git index, with a two-line jump.
local function git(...)
  local command = { 'git', '-C', directory }
  vim.list_extend(command, { ... })
  local result = vim.system(command, { text = true }):wait()
  check(result.code == 0, result.stderr)
end
git('init', '-q')
local gitpath = directory .. '/tracked.txt'
write(gitpath, { 'a', 'b', 'c', 'd' })
git('add', 'tracked.txt')
write(gitpath, { 'a', 'b', 'changed', 'd' })
local gitbuf = open(gitpath)
require('gitsigns').attach(gitbuf)
check(
  vim.wait(2000, function()
    local hunks = require('gitsigns').get_hunks(gitbuf)
    return hunks and #hunks == 1
  end, 20),
  'Git hunk was not detected'
)
api.nvim_win_set_cursor(0, { 1, 0 })
vim.fn.maparg(']c', 'n', false, true).callback()
settle()
check(api.nvim_win_get_cursor(0)[1] == 3, 'Git navigation landed at wrong line')
check(#marks(gitbuf, 'JumpCursorBeacon') == 1, 'short Git jump has no beacon')

-- Large files and long lines enter light mode, normal files stay unaffected, and override restores behavior.
local bigpath = directory .. '/large.txt'
write(bigpath, { string.rep('x', 1024 * 1024) })
local bigbuf = open(bigpath)
vim.bo.filetype = 'experience'
settle()
check(vim.b[bigbuf].large_file, 'large file not detected before plugins attach')
check(vim.bo[bigbuf].syntax == 'OFF' and not vim.diagnostic.is_enabled { bufnr = bigbuf }, 'light mode did not reduce analysis')
check(formatting.on_save(bigbuf) == nil, 'large file formats automatically')
require('custom.large_file').toggle()
check(not vim.b[bigbuf].large_file and vim.diagnostic.is_enabled { bufnr = bigbuf }, 'full mode did not restore diagnostics')
check(formatting.on_save(bigbuf) ~= nil, 'full mode did not restore formatting')
local longpath = directory .. '/long.txt'
write(longpath, { string.rep('x', 2100) })
local longbuf = open(longpath)
check(vim.b[longbuf].large_file, 'long-line file not detected')
local smallpath = directory .. '/small.txt'
write(smallpath, { 'small file' })
local smallbuf = open(smallpath)
check(not vim.b[smallbuf].large_file and vim.diagnostic.is_enabled { bufnr = smallbuf }, 'light mode leaked to normal file')

-- Toggle an already highlighted code file; disabling light mode restores highlighting.
local codepath = directory .. '/small.lua'
write(codepath, { 'local function value()', '  return 42', 'end' })
local codebuf = open(codepath)
require('lazy').load { plugins = { 'nvim-ufo', 'indent-blankline.nvim', 'nvim-treesitter-context', 'dropbar.nvim', 'render-markdown.nvim' } }
check(vim.treesitter.highlighter.active[codebuf], 'normal code has no Treesitter highlighting')
require('custom.large_file').toggle()
settle()
check(not vim.treesitter.highlighter.active[codebuf], 'light mode left Treesitter running')
check(vim.wo.winbar == '', 'light mode left the breadcrumb visible')
require('custom.large_file').toggle()
settle()
check(vim.treesitter.highlighter.active[codebuf], 'full mode did not restore Treesitter')
check(vim.wo.winbar ~= '', 'full mode did not restore breadcrumbs')
api.nvim_set_current_buf(smallbuf)

-- The same LSP document-jump path used by a single definition result also marks short jumps.
api.nvim_set_current_buf(codebuf)
api.nvim_win_set_cursor(0, { 1, 0 })
api.nvim_exec_autocmds('CursorMoved', { buffer = codebuf })
vim.wait(400)
vim.lsp.util.show_document({
  uri = vim.uri_from_bufnr(codebuf),
  range = { start = { line = 1, character = 2 }, ['end'] = { line = 1, character = 8 } },
}, 'utf-16', { focus = true })
api.nvim_exec_autocmds('CursorMoved', { buffer = codebuf })
settle()
check(api.nvim_win_get_cursor(0)[1] == 2, 'definition navigation failed')
check(#marks(codebuf, 'JumpCursorBeacon') > 0, 'short definition jump has no beacon')
api.nvim_set_current_buf(smallbuf)

-- Repeated pulses and buffer switches must not leave highlights behind.
local beacon = require 'custom.jump_beacon'
beacon.pulse()
check(#marks(smallbuf, 'JumpCursorBeacon') == 1, 'beacon missing')
beacon.pulse()
check(#marks(smallbuf, 'JumpCursorBeacon') == 1, 'beacons accumulate')
local nextbuf = new_buffer()
beacon.pulse()
check(#marks(smallbuf, 'JumpCursorBeacon') == 0, 'old buffer beacon left behind')
check(
  vim.wait(1000, function()
    return #marks(nextbuf, 'JumpCursorBeacon') == 0
  end, 10),
  'beacon did not expire'
)

vim.notify = notify
print 'experience checks passed'
vim.cmd 'noautocmd qa!'
