local M = {}
local api = vim.api
local history, active = {}, nil

local function label(entry)
  local preview = table.concat(entry.lines, ' ↵ '):gsub('%s+', ' ')
  return ('%s:%d · %s'):format(entry.source, entry.line, vim.fn.strcharpart(preview, 0, 100))
end

-- Record native put edits so cycling removes only inserted text, preserving
-- marks in the surrounding text (including return tickets and diagnostics).
local function put(index)
  local entry = active.entries[index]
  api.nvim_win_set_cursor(0, active.cursor)
  local base = active.cursor[1] - 1
  local mirror = api.nvim_buf_get_lines(0, base, math.min(api.nvim_buf_line_count(0), base + #entry.lines), false)
  local inverse, recording = {}, true
  api.nvim_buf_attach(active.buf, false, {
    on_bytes = function(_, buf, _, row, col, _, old_rows, old_col, _, new_rows, new_col)
      if not recording then
        return true
      end
      local linewise = col == 0 and old_col == 0 and new_col == 0 and (old_rows > 0 or new_rows > 0)
      local first = row - base + 1
      -- Block puts beyond EOF report the appended newline as a byte column.
      if not linewise and first > #mirror then
        linewise, new_rows, new_col = true, 1, 0
      end
      local old_count = old_rows + (linewise and 0 or 1)
      local new_count = new_rows + (linewise and 0 or 1)
      local removed = vim.list_slice(mirror, first, first + old_count - 1)
      if not linewise then
        local ending = old_rows == 0 and col + old_col or old_col
        removed[#removed] = removed[#removed]:sub(1, ending)
        removed[1] = removed[1]:sub(col + 1)
      end
      inverse[#inverse + 1] = {
        row = row,
        col = col,
        end_row = row + new_rows,
        end_col = new_rows == 0 and col + new_col or new_col,
        lines = removed,
        linewise = linewise,
      }
      local replacement = api.nvim_buf_get_lines(buf, row, row + new_count, false)
      for i = 1, math.min(old_count, new_count) do
        mirror[first + i - 1] = replacement[i]
      end
      for _ = new_count + 1, old_count do
        table.remove(mirror, first + new_count)
      end
      for i = old_count + 1, new_count do
        table.insert(mirror, first + i - 1, replacement[i])
      end
    end,
  })
  local ok, err = pcall(api.nvim_put, entry.lines, entry.type, true, true)
  recording, mirror = false, nil
  active.inverse, inverse = inverse, nil
  if not ok then
    error(err)
  end
  active.index = index
  active.tick = api.nvim_buf_get_changedtick(0)
  vim.notify(('Paste %d/%d · %s'):format(index, #active.entries, label(entry)))
end

function M.paste(index)
  if #history == 0 then
    vim.notify 'Copy some text first; history records explicit yanks'
    return
  end
  if not vim.bo.modifiable or vim.bo.buftype ~= '' then
    vim.notify 'Paste history requires an editable file'
    return
  end
  local cursor = api.nvim_win_get_cursor(0)
  active = {
    buf = api.nvim_get_current_buf(),
    cursor = cursor,
    entries = vim.deepcopy(history),
  }
  vim.go.undolevels = vim.go.undolevels -- Keep each paste/cycle independently undoable.
  put(index or 1)
end

function M.cycle(direction)
  if not active or active.buf ~= api.nvim_get_current_buf() or active.tick ~= api.nvim_buf_get_changedtick(0) then
    active = nil
    vim.notify 'Paste with Space p first; cycling stops after another edit'
    return
  end
  if not vim.bo.modifiable or #active.entries < 2 then
    return
  end
  local index = (active.index - 1 + direction) % #active.entries + 1
  vim.go.undolevels = vim.go.undolevels
  for i = #active.inverse, 1, -1 do
    local edit = active.inverse[i]
    if edit.linewise then
      api.nvim_buf_set_lines(0, edit.row, edit.end_row, false, edit.lines)
    else
      api.nvim_buf_set_text(0, edit.row, edit.col, edit.end_row, edit.end_col, edit.lines)
    end
    vim.cmd.undojoin()
  end
  put(index)
end

function M.choose()
  if #history == 0 then
    vim.notify 'Copy history is empty'
    return
  end
  local buf, tick, cursor = api.nvim_get_current_buf(), api.nvim_buf_get_changedtick(0), api.nvim_win_get_cursor(0)
  local entries = vim.list_slice(history)
  vim.ui.select(entries, { prompt = 'Paste copied text', format_item = label }, function(entry)
    if not entry then
      return
    end
    if api.nvim_get_current_buf() ~= buf or api.nvim_buf_get_changedtick(buf) ~= tick then
      vim.notify 'Paste cancelled: target buffer changed'
      return
    end
    for index, candidate in ipairs(history) do
      if candidate == entry then
        api.nvim_win_set_cursor(0, cursor)
        M.paste(index)
        return
      end
    end
  end)
end

function M.clear()
  history, active = {}, nil
  vim.notify 'Copy history cleared'
end

function M.setup()
  api.nvim_create_autocmd('TextYankPost', {
    group = api.nvim_create_augroup('copy-history', { clear = true }),
    callback = function()
      local event = vim.v.event
      if event.operator ~= 'y' or event.regname == '_' or #event.regcontents == 0 then
        return
      end
      local lines = vim.deepcopy(event.regcontents)
      if #table.concat(lines, '\n') > 100 * 1024 then
        return
      end
      local entry = {
        lines = lines,
        type = event.regtype,
        source = api.nvim_buf_get_name(0) == '' and '[No Name]' or vim.fn.fnamemodify(api.nvim_buf_get_name(0), ':~:.'),
        line = vim.fn.getpos("'[")[2],
      }
      for i = #history, 1, -1 do
        if history[i].type == entry.type and vim.deep_equal(history[i].lines, lines) then
          table.remove(history, i)
        end
      end
      table.insert(history, 1, entry)
      history[31] = nil
    end,
  })
  vim.keymap.set('n', '<leader>p', M.paste, { desc = 'Paste latest copy (cycle with [y / ]y)' })
  vim.keymap.set('n', ']y', function()
    M.cycle(1)
  end, { desc = 'Paste older copy' })
  vim.keymap.set('n', '[y', function()
    M.cycle(-1)
  end, { desc = 'Paste newer copy' })
  vim.keymap.set('n', '<leader>sy', M.choose, { desc = 'Search copy history' })
  vim.keymap.set('n', '<leader>cX', M.clear, { desc = 'Clear copy history' })
end

return M
