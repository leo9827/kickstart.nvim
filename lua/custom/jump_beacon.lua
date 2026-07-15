local M = {}

local api = vim.api
local uv = vim.uv or vim.loop
local namespace = api.nvim_create_namespace 'JumpCursorBeacon'
local group = api.nvim_create_augroup('JumpCursorBeacon', { clear = true })

local enabled = vim.g.jump_cursor_beacon_enabled ~= false
local min_jump = vim.g.jump_cursor_beacon_min_distance or 8
local strong_ms = vim.g.jump_cursor_beacon_strong_ms or 120
local soft_ms = vim.g.jump_cursor_beacon_soft_ms or 220
local cooldown_ms = vim.g.jump_cursor_beacon_cooldown_ms or 120

local state = {
  last_line_by_win = {},
  last_pulse_at_by_win = {},
  pulse_id_by_win = {},
}

local function clear(bufnr)
  if api.nvim_buf_is_valid(bufnr) then
    api.nvim_buf_clear_namespace(bufnr, namespace, 0, -1)
  end
end

local function at_position(winid, bufnr, lnum)
  return api.nvim_win_is_valid(winid) and api.nvim_win_get_buf(winid) == bufnr and api.nvim_win_get_cursor(winid)[1] == lnum
end

local function highlight(bufnr, lnum, group_name)
  local line_count = api.nvim_buf_line_count(bufnr)
  if line_count == 0 then
    return
  end
  lnum = math.min(math.max(lnum, 1), line_count)

  api.nvim_buf_clear_namespace(bufnr, namespace, 0, -1)
  api.nvim_buf_set_extmark(bufnr, namespace, lnum - 1, 0, {
    line_hl_group = group_name,
    priority = 220,
  })
end

local function animate(winid, bufnr, lnum)
  local pulse_id = (state.pulse_id_by_win[winid] or 0) + 1
  state.pulse_id_by_win[winid] = pulse_id
  highlight(bufnr, lnum, 'JumpCursorBeaconStrong')

  vim.defer_fn(function()
    if state.pulse_id_by_win[winid] ~= pulse_id then
      return
    end
    if not at_position(winid, bufnr, lnum) then
      clear(bufnr)
      return
    end

    highlight(bufnr, lnum, 'JumpCursorBeaconSoft')
    vim.defer_fn(function()
      if state.pulse_id_by_win[winid] == pulse_id then
        clear(bufnr)
      end
    end, soft_ms)
  end, strong_ms)
end

function M.pulse(opts)
  opts = opts or {}
  if not opts.force and not enabled then
    return false
  end

  local winid = api.nvim_get_current_win()
  local bufnr = api.nvim_win_get_buf(winid)
  if vim.bo[bufnr].buftype ~= '' then
    return false
  end

  local lnum = api.nvim_win_get_cursor(winid)[1]
  state.last_line_by_win[winid] = lnum
  animate(winid, bufnr, lnum)
  return true
end

local function repeat_search(motion)
  local before = api.nvim_win_get_cursor(0)
  vim.cmd.normal { bang = true, args = { tostring(vim.v.count1) .. motion } }
  local after = api.nvim_win_get_cursor(0)
  if after[1] ~= before[1] or after[2] ~= before[2] then
    M.pulse()
  end
end

function M.setup()
  vim.keymap.set('n', 'n', function()
    repeat_search 'n'
  end, { desc = 'Next search result' })
  vim.keymap.set('n', 'N', function()
    repeat_search 'N'
  end, { desc = 'Previous search result' })
  vim.keymap.set('n', '<leader>tc', function()
    M.pulse { force = true }
  end, { desc = 'Track cursor' })

  api.nvim_create_autocmd('CursorMoved', {
    group = group,
    callback = function()
      if not enabled or vim.fn.mode(1):sub(1, 1) ~= 'n' then
        return
      end

      local winid = api.nvim_get_current_win()
      local bufnr = api.nvim_win_get_buf(winid)
      local lnum = api.nvim_win_get_cursor(winid)[1]
      local previous = state.last_line_by_win[winid]
      state.last_line_by_win[winid] = lnum

      if vim.bo[bufnr].buftype ~= '' or not previous or math.abs(lnum - previous) < min_jump then
        return
      end

      local now_ms = uv.now()
      if now_ms - (state.last_pulse_at_by_win[winid] or 0) < cooldown_ms then
        return
      end

      state.last_pulse_at_by_win[winid] = now_ms
      animate(winid, bufnr, lnum)
    end,
  })

  api.nvim_create_autocmd({ 'BufEnter', 'WinEnter' }, {
    group = group,
    callback = function()
      local winid = api.nvim_get_current_win()
      state.last_line_by_win[winid] = api.nvim_win_get_cursor(winid)[1]
    end,
  })
end

return M
