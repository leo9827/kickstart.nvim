local M = {}
local api = vim.api
local last

local function belongs(buf, root)
  local name = api.nvim_buf_get_name(buf)
  return vim.fs.relpath(root, name) ~= nil and (name:match '%.go$' or name:match '/go%.mod$' or name:match '/go%.sum$' or name:match '/go%.work$')
end

local function nearest()
  local ok, node = pcall(vim.treesitter.get_node)
  if not ok then
    return
  end
  while node do
    if node:type() == 'function_declaration' then
      local name = node:field('name')[1]
      name = name and vim.treesitter.get_node_text(name, 0)
      if name and (name == 'Test' or name:match '^Test[^a-z]' or name:match '^Example' or name == 'Fuzz' or name:match '^Fuzz[^a-z]') then
        return name
      end
      return
    end
    node = node:parent()
  end
end

local function append(run, text, test)
  for line in (text .. '\n'):gmatch '(.-)\n' do
    if line ~= '' then
      line = #line > 4096 and line:sub(1, 4096) .. ' [truncated]' or line
      run.log[#run.log + 1] = line
      if #run.log > 2000 then
        table.remove(run.log, 1)
      end
      local file, row, message = line:match '^%s*(.-%.go):(%d+):%s*(.*)'
      if file and #run.locations < 2000 then
        local column, rest = message:match '^(%d+):%s*(.*)'
        run.locations[#run.locations + 1] = {
          filename = vim.fs.normalize(file:sub(1, 1) == '/' and file or run.cwd .. '/' .. file),
          lnum = tonumber(row),
          col = tonumber(column) or 1,
          text = rest or message,
          type = 'E',
          test = test,
        }
      end
    end
  end
end

local function event(run, line)
  local ok, value = pcall(vim.json.decode, line)
  if not ok or type(value) ~= 'table' then
    append(run, line)
    return
  end
  if value.Output then
    append(run, value.Output, value.Test)
  end
  if value.Test and value.Action == 'fail' then
    run.failed[value.Test] = true
  end
  if value.Test and not value.Test:find('/', 1, true) and run.counts[value.Action] then
    run.counts[value.Action] = run.counts[value.Action] + 1
  end
end

local function stop(run)
  if run and run.running and run.process then
    if vim.fn.has 'win32' == 1 then
      run.process:kill(15)
    else
      local ok, err = vim.uv.kill(-run.process.pid, 15) -- Stop the test subprocess too.
      if not ok then
        vim.notify('Could not cancel Go tests: ' .. tostring(err), vim.log.levels.WARN)
        return
      end
    end
    run.cancelled = true
  end
end

local function outcome(run)
  if run.running then
    return 'running'
  end
  if run.cancelled then
    return 'cancelled'
  end
  if run.code ~= 0 then
    return 'FAIL'
  end
  if run.counts.pass + run.counts.fail + run.counts.skip == 0 then
    return run.test and 'no matching tests' or 'no tests'
  end
  if run.counts.pass == 0 and run.counts.fail == 0 then
    return 'skipped'
  end
  return 'pass'
end

local function summary(run)
  return 'TEST ' .. outcome(run) .. (run.stale and ' (stale)' or '')
end

local function start(spec)
  if last and last.running then
    vim.notify('A Go test is running · Space Tk to cancel', vim.log.levels.WARN)
    return
  end
  local ticks = {}
  for _, buf in ipairs(api.nvim_list_bufs()) do
    if api.nvim_buf_is_loaded(buf) and belongs(buf, spec.root) then
      if vim.bo[buf].modified then
        vim.notify('Save Go changes before testing: ' .. vim.fn.fnamemodify(api.nvim_buf_get_name(buf), ':t'), vim.log.levels.WARN)
        return
      end
      ticks[buf] = api.nvim_buf_get_changedtick(buf)
    end
  end
  local run = vim.tbl_extend('force', spec, {
    running = true,
    counts = { pass = 0, fail = 0, skip = 0 },
    log = {},
    locations = {},
    failed = {},
    ticks = ticks,
  })
  last = run
  local command = { 'go', 'test', '-json', '-count=1', '-timeout=2m' }
  if spec.test then
    vim.list_extend(command, { '-run', '^' .. spec.test .. '$' })
  end
  command[#command + 1] = '.'
  local partial = { stdout = '', stderr = '' }
  local function stream(channel)
    return vim.schedule_wrap(function(err, data)
      if err then
        append(run, tostring(err))
      end
      if not data then
        return
      end
      local combined = partial[channel] .. data
      local start_at = 1
      while true do
        local ending = combined:find('\n', start_at, true)
        if not ending then
          break
        end
        local line = combined:sub(start_at, ending - 1)
        if channel == 'stdout' then
          event(run, line)
        else
          append(run, line)
        end
        start_at = ending + 1
      end
      partial[channel] = combined:sub(start_at)
      if #partial[channel] > 1024 * 1024 then
        partial[channel] = ''
        append(run, '[Oversized output omitted]')
      end
      vim.cmd.redrawstatus()
    end)
  end
  local ok, process = pcall(
    vim.system,
    command,
    {
      cwd = run.cwd,
      text = true,
      detach = true,
      stdout = stream 'stdout',
      stderr = stream 'stderr',
    },
    vim.schedule_wrap(function(result)
      for channel, tail in pairs(partial) do
        if tail ~= '' then
          if channel == 'stdout' then
            event(run, tail)
          else
            append(run, tail)
          end
        end
      end
      run.running, run.code = false, result.code
      for buf, tick in pairs(run.ticks) do
        if not api.nvim_buf_is_loaded(buf) or api.nvim_buf_get_changedtick(buf) ~= tick then
          run.stale = true
        end
      end
      local status = outcome(run)
      vim.notify(
        ('Go test %s · %d passed, %d failed, %d skipped%s · Space To for output'):format(
          status,
          run.counts.pass,
          run.counts.fail,
          run.counts.skip,
          run.stale and ' (stale)' or ''
        ),
        (status == 'pass' or status == 'skipped' or run.cancelled) and vim.log.levels.INFO or vim.log.levels.WARN
      )
      vim.cmd.redrawstatus()
    end)
  )
  if not ok then
    run.running, run.code = false, -1
    append(run, tostring(process))
    vim.notify('Could not start Go tests: ' .. tostring(process), vim.log.levels.ERROR)
    return
  end
  run.process = process
  vim.cmd.redrawstatus()
end

function M.run(kind)
  local file = api.nvim_buf_get_name(0)
  if vim.bo.buftype ~= '' or not file:match '%.go$' then
    vim.notify 'Open a Go source file to run tests'
    return
  end
  local test = kind == 'nearest' and nearest() or nil
  if kind == 'nearest' and not test then
    vim.notify 'Place the cursor inside a test, example, or fuzz function; Space Tp runs the package'
    return
  end
  start { cwd = vim.fs.dirname(file), root = vim.fs.root(0, { 'go.mod', '.git' }) or vim.fs.dirname(file), test = test }
end

function M.rerun()
  if last then
    start { cwd = last.cwd, root = last.root, test = last.test }
  else
    vim.notify 'No previous Go test run'
  end
end

function M.cancel()
  stop(last)
end

function M.status()
  local file = api.nvim_buf_get_name(0)
  if not last or not file:match '%.go$' or vim.fs.dirname(file) ~= last.cwd then
    return ''
  end
  return summary(last)
end

function M.output()
  if not last then
    vim.notify 'No Go test results yet'
    return
  end
  local lines = { 'Go test · ' .. last.cwd .. ' · ' .. (last.test or 'package'), summary(last), '' }
  vim.list_extend(lines, last.log)
  vim.cmd 'botright 12new'
  vim.bo.buftype, vim.bo.bufhidden, vim.bo.swapfile = 'nofile', 'wipe', false
  api.nvim_buf_set_lines(0, 0, -1, false, lines)
  vim.bo.modifiable, vim.bo.modified = false, false
  vim.keymap.set('n', 'q', '<cmd>close<CR>', { buffer = true, desc = 'Close test output' })
end

function M.failures()
  if not last or last.running then
    vim.notify 'No completed Go test results yet'
    return
  end
  local items = {}
  for _, location in ipairs(last.locations) do
    if last.failed[location.test] or not location.test and last.code ~= 0 then
      local item = vim.deepcopy(location)
      item.test = nil
      items[#items + 1] = item
    end
  end
  if #items == 0 then
    M.output()
    return
  end
  vim.fn.setqflist({}, ' ', { title = 'Go test failures' .. (last.stale and ' (stale)' or ''), items = items })
  vim.cmd.copen()
end

function M.setup()
  local group = api.nvim_create_augroup('go-test-feedback', { clear = true })
  api.nvim_create_autocmd({ 'TextChanged', 'TextChangedI', 'BufWritePost', 'FileChangedShellPost' }, {
    group = group,
    callback = function(e)
      if
        last
        and belongs(e.buf, last.root)
        and (last.ticks[e.buf] ~= api.nvim_buf_get_changedtick(e.buf) or e.event ~= 'TextChanged' and e.event ~= 'TextChangedI')
      then
        last.stale = true
        vim.cmd.redrawstatus()
      end
    end,
  })
  api.nvim_create_autocmd('VimLeavePre', {
    group = group,
    callback = function()
      stop(last)
    end,
  })
  vim.keymap.set('n', '<leader>Tn', function()
    M.run 'nearest'
  end, { desc = 'Test nearest Go function' })
  vim.keymap.set('n', '<leader>Tp', function()
    M.run 'package'
  end, { desc = 'Test Go package' })
  vim.keymap.set('n', '<leader>Tr', M.rerun, { desc = 'Rerun last Go test' })
  vim.keymap.set('n', '<leader>Tf', M.failures, { desc = 'Show Go test failures' })
  vim.keymap.set('n', '<leader>To', M.output, { desc = 'Show Go test output' })
  vim.keymap.set('n', '<leader>Tk', M.cancel, { desc = 'Cancel Go test' })
end

return M
