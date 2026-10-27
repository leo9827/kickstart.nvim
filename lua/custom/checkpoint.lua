local M = {}
local api = vim.api
local entries = {}

local function eligible(buf)
  return api.nvim_buf_is_loaded(buf)
    and vim.bo[buf].buftype == ''
    and vim.bo[buf].buflisted
    and api.nvim_buf_get_offset(buf, api.nvim_buf_line_count(buf)) < 1024 * 1024
end

local function capture(buf)
  if not eligible(buf) then
    vim.notify('Checkpoint skipped: use a normal file below 1 MiB', vim.log.levels.WARN)
    return
  end
  if not entries[buf] and vim.tbl_count(entries) >= 20 then
    vim.notify('Checkpoint limit reached (20 files); clear one first', vim.log.levels.WARN)
    return
  end
  entries[buf] = {
    lines = api.nvim_buf_get_lines(buf, 0, -1, false),
    name = api.nvim_buf_get_name(buf),
    filetype = vim.bo[buf].filetype,
    time = os.date '%H:%M:%S',
  }
  vim.notify('Checkpoint saved for ' .. vim.fn.fnamemodify(entries[buf].name, ':t'))
end

function M.save()
  local buf = api.nvim_get_current_buf()
  if not entries[buf] then
    capture(buf)
    return
  end
  vim.ui.select({ 'Keep existing', 'Replace checkpoint' }, { prompt = 'This file already has a checkpoint' }, function(choice)
    if choice == 'Replace checkpoint' then
      capture(buf)
    end
  end)
end

local function review(buf)
  local entry = entries[buf]
  if not entry or not eligible(buf) then
    vim.notify 'Checkpoint file is unavailable or exceeds 1 MiB'
    return
  end
  local after = api.nvim_buf_get_lines(buf, 0, -1, false)
  if vim.deep_equal(entry.lines, after) then
    vim.notify('No changes since checkpoint ' .. entry.time)
    return
  end
  require('custom.diff_review').open(entry.lines, after, entry.filetype, {
    'Checkpoint ' .. entry.time .. ' · ' .. vim.fn.fnamemodify(entry.name, ':~:.'),
    'Current edits · ' .. vim.fn.fnamemodify(api.nvim_buf_get_name(buf), ':~:.'),
  })
end

function M.review()
  local buffers = vim.tbl_keys(entries)
  table.sort(buffers)
  if #buffers == 0 then
    vim.notify 'No checkpoints · Space wc to capture this file'
    return
  end
  vim.ui.select(buffers, {
    prompt = 'Review checkpoint',
    format_item = function(buf)
      return entries[buf].time .. ' · ' .. vim.fn.fnamemodify(entries[buf].name, ':~:.')
    end,
  }, function(buf)
    if buf then
      review(buf)
    end
  end)
end

function M.clear()
  entries[api.nvim_get_current_buf()] = nil
  vim.notify 'Checkpoint cleared for this file'
end

function M.setup()
  api.nvim_create_autocmd('BufWipeout', {
    group = api.nvim_create_augroup('editing-checkpoints', { clear = true }),
    callback = function(event)
      entries[event.buf] = nil
    end,
  })
  vim.keymap.set('n', '<leader>wc', M.save, { desc = 'Capture file checkpoint' })
  vim.keymap.set('n', '<leader>wv', M.review, { desc = 'View checkpoint changes' })
  vim.keymap.set('n', '<leader>wC', M.clear, { desc = 'Clear file checkpoint' })
end

return M
