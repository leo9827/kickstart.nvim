local M = {}
local api = vim.api
local namespace = api.nvim_create_namespace 'JumpCursorBeacon'
local state, active, last_pulse, scheduled = {}, {}, {}, {}

local function position()
  local cursor = api.nvim_win_get_cursor(0)
  local jumps, index = unpack(vim.fn.getjumplist())
  local last = jumps[#jumps] or {}
  return {
    buf = api.nvim_get_current_buf(),
    line = cursor[1],
    col = cursor[2],
    jump = table.concat({ index, last.bufnr or 0, last.lnum or 0, last.col or 0 }, ':'),
  }
end

local function clear(mark)
  if mark and api.nvim_buf_is_valid(mark.buf) then
    pcall(api.nvim_buf_del_extmark, mark.buf, namespace, mark.id)
  end
end

function M.pulse(opts)
  if not (opts and opts.force) and vim.g.jump_cursor_beacon_enabled == false then
    return false
  end
  local winid = api.nvim_get_current_win()
  local pos = position()
  if vim.bo[pos.buf].buftype ~= '' or vim.b[pos.buf].large_file then
    return false
  end
  state[winid] = pos
  last_pulse[winid] = vim.uv.now()
  clear(active[winid])
  local mark = {
    buf = pos.buf,
    id = api.nvim_buf_set_extmark(pos.buf, namespace, pos.line - 1, 0, {
      line_hl_group = 'JumpCursorBeaconStrong',
      priority = 220,
    }),
  }
  active[winid] = mark
  vim.defer_fn(function()
    if active[winid] ~= mark then
      return
    end
    if not api.nvim_win_is_valid(winid) or api.nvim_win_get_buf(winid) ~= pos.buf or api.nvim_win_get_cursor(winid)[1] ~= pos.line then
      clear(mark)
      active[winid] = nil
      return
    end
    api.nvim_buf_set_extmark(pos.buf, namespace, pos.line - 1, 0, {
      id = mark.id,
      line_hl_group = 'JumpCursorBeaconSoft',
      priority = 220,
    })
    vim.defer_fn(function()
      clear(mark)
      if active[winid] == mark then
        active[winid] = nil
      end
    end, vim.g.jump_cursor_beacon_soft_ms or 220)
  end, vim.g.jump_cursor_beacon_strong_ms or 120)
  return true
end

-- For synchronous motions; asynchronous pickers use their selection callback.
function M.after(action)
  local before = position()
  action()
  local after = position()
  if before.buf ~= after.buf or before.line ~= after.line or before.col ~= after.col then
    M.pulse()
  end
end

function M.setup()
  local group = api.nvim_create_augroup('JumpCursorBeacon', { clear = true })
  for _, motion in ipairs { 'n', 'N' } do
    vim.keymap.set('n', motion, function()
      M.after(function()
        vim.cmd.normal { bang = true, args = { tostring(vim.v.count1) .. motion } }
      end)
    end, { desc = motion == 'n' and 'Next search result' or 'Previous search result' })
  end
  vim.keymap.set('n', '<leader>tc', function()
    M.pulse { force = true }
  end, { desc = 'Track cursor' })
  api.nvim_create_autocmd({ 'CursorMoved', 'BufEnter', 'WinEnter' }, {
    group = group,
    callback = function()
      if vim.fn.mode(1):sub(1, 1) ~= 'n' or vim.bo.buftype ~= '' then
        return
      end
      local winid = api.nvim_get_current_win()
      local current, previous = position(), state[winid]
      state[winid] = current
      if not previous then
        return
      end
      local changed_buffer = current.buf ~= previous.buf
      local moved = changed_buffer or current.line ~= previous.line or current.col ~= previous.col
      local jumped = changed_buffer or current.jump ~= previous.jump or math.abs(current.line - previous.line) >= (vim.g.jump_cursor_beacon_min_distance or 8)
      local cooldown_elapsed = vim.uv.now() - (last_pulse[winid] or 0) >= (vim.g.jump_cursor_beacon_cooldown_ms or 120)
      if moved and jumped and (cooldown_elapsed or changed_buffer) and not scheduled[winid] then
        scheduled[winid] = true
        vim.schedule(function()
          scheduled[winid] = nil
          if api.nvim_get_current_win() == winid and api.nvim_get_current_buf() == current.buf then
            M.pulse()
          end
        end)
      end
    end,
  })
  api.nvim_create_autocmd('User', {
    group = group,
    pattern = 'TelescopeFindPre',
    callback = function()
      require('telescope.actions.set').select:enhance {
        post = function()
          local winid, bufnr = api.nvim_get_current_win(), api.nvim_get_current_buf()
          vim.schedule(function()
            if api.nvim_get_current_win() == winid and api.nvim_get_current_buf() == bufnr then
              M.pulse()
            end
          end)
        end,
      }
    end,
  })
  api.nvim_create_autocmd('WinClosed', {
    group = group,
    callback = function(event)
      local winid = tonumber(event.match)
      clear(active[winid])
      state[winid], active[winid], last_pulse[winid], scheduled[winid] = nil, nil, nil, nil
    end,
  })
end

return M
