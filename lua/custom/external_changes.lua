local M = {}
local api = vim.api
local baseline, pending, latest = {}, {}, {}
local namespace = api.nvim_create_namespace 'ExternalFileChanges'
local checking = false

local function snapshot(bufnr)
  if not api.nvim_buf_is_loaded(bufnr) or vim.bo[bufnr].buftype ~= '' then
    return
  end
  local count = api.nvim_buf_line_count(bufnr)
  if vim.b[bufnr].large_file or api.nvim_buf_get_offset(bufnr, count) >= 1024 * 1024 then
    return
  end
  return api.nvim_buf_get_lines(bufnr, 0, -1, false)
end

local function changed(event)
  local bufnr = event.buf
  local before = pending[bufnr]
  pending[bufnr] = nil
  if not before or vim.bo[bufnr].modified then
    return
  end
  local after = snapshot(bufnr)
  if not after or vim.deep_equal(before, after) then
    return
  end
  local change = { before = before, after = after, filetype = vim.bo[bufnr].filetype }
  latest[bufnr] = change
  api.nvim_buf_clear_namespace(bufnr, namespace, 0, -1)
  local before_text = table.concat(before, '\n') .. '\n'
  local after_text = table.concat(after, '\n') .. '\n'
  local hunks = vim.text.diff(before_text, after_text, { result_type = 'indices' })
  local marked = 0
  for _, hunk in ipairs(hunks) do
    local new_start, new_count = hunk[3], hunk[4]
    local deleted = new_count == 0
    local start = deleted and math.max(1, new_start) or new_start
    local finish = math.min(#after, start + math.max(1, new_count) - 1)
    for line = start, finish do
      if marked >= 200 then
        break
      end
      api.nvim_buf_set_extmark(bufnr, namespace, line - 1, 0, {
        line_hl_group = deleted and 'DiffDelete' or 'DiffChange',
        priority = 210,
      })
      marked = marked + 1
    end
  end
  local name = vim.fn.fnamemodify(api.nvim_buf_get_name(bufnr), ':t')
  vim.schedule(function()
    vim.notify(('Updated externally: %s (%d changes) · <Space>we to review'):format(name, #hunks), vim.log.levels.INFO)
  end)
  vim.defer_fn(function()
    if api.nvim_buf_is_valid(bufnr) and latest[bufnr] == change then
      api.nvim_buf_clear_namespace(bufnr, namespace, 0, -1)
    end
  end, 1500)
end

function M.review()
  local change = latest[api.nvim_get_current_buf()]
  if not change then
    vim.notify('No external change captured for this file', vim.log.levels.INFO)
    return
  end
  require('custom.diff_review').open(change.before, change.after, change.filetype, { 'Before external update', 'After external update' })
end

function M.setup()
  local group = api.nvim_create_augroup('external-file-changes', { clear = true })
  api.nvim_create_autocmd('BufReadPre', {
    group = group,
    callback = function(event)
      pending[event.buf] = baseline[event.buf]
    end,
  })
  api.nvim_create_autocmd('BufReadPost', {
    group = group,
    callback = function(event)
      baseline[event.buf] = snapshot(event.buf)
      local captured = pending[event.buf]
      vim.schedule(function()
        if pending[event.buf] == captured then
          pending[event.buf] = nil
        end
      end)
    end,
  })
  api.nvim_create_autocmd('BufWritePost', {
    group = group,
    callback = function(event)
      baseline[event.buf] = snapshot(event.buf)
    end,
  })
  api.nvim_create_autocmd('FileChangedShellPost', { group = group, callback = changed })
  api.nvim_create_autocmd('BufWipeout', {
    group = group,
    callback = function(event)
      baseline[event.buf], pending[event.buf], latest[event.buf] = nil, nil, nil
    end,
  })
  api.nvim_create_autocmd({ 'FocusGained', 'BufEnter', 'CursorHold' }, {
    group = group,
    callback = function()
      if checking or vim.fn.mode():match '[ciR]' then
        return
      end
      checking = true
      vim.schedule(function()
        checking = false
        if not vim.fn.mode():match '[ciR]' and vim.fn.getcmdwintype() == '' then
          vim.cmd.checktime()
        end
      end)
    end,
  })
  vim.keymap.set('n', '<leader>we', M.review, { desc = 'Review last external file update' })
end

return M
