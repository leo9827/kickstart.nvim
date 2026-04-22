-- Custom keymaps extracted from remap.lua
-- Only keep non-conflicting, useful keymaps
local function smooth_half_page(direction)
  local lines = math.max(math.floor(vim.api.nvim_win_get_height(0) / 2), 1)
  local duration = 120
  local ok, neoscroll = pcall(require, 'neoscroll')

  if ok then
    neoscroll.scroll(direction * lines, { move_cursor = true, duration = duration, easing = 'sine' })
    vim.defer_fn(function()
      pcall(vim.cmd, 'normal! zz')
    end, duration)
  else
    if direction > 0 then
      vim.cmd 'normal! <C-d>'
    else
      vim.cmd 'normal! <C-u>'
    end
    vim.cmd 'normal! zz'
  end
end

-- Visual mode: move lines up/down
vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv", { desc = 'Move line down' })
vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv", { desc = 'Move line up' })

-- Keep cursor centered when joining lines
vim.keymap.set('n', 'J', 'mzJ`z', { desc = 'Join lines (cursor centered)' })

-- Keep cursor centered when scrolling
vim.keymap.set('n', '<C-d>', function()
  smooth_half_page(1)
end, { desc = 'Scroll down (centered)' })
vim.keymap.set('n', '<C-u>', function()
  smooth_half_page(-1)
end, { desc = 'Scroll up (centered)' })

-- Format paragraph and return to position
vim.keymap.set('n', '=ap', "ma=ap'a", { desc = 'Format paragraph' })

-- Better paste in visual mode (don't yank replaced text)
vim.keymap.set('x', '<leader>p', [["_dP]], { desc = 'Paste without yanking' })

-- System clipboard operations
vim.keymap.set({ 'n', 'v' }, '<leader>y', [["+y]], { desc = 'Yank to system clipboard' })
vim.keymap.set('n', '<leader>Y', [["+Y]], { desc = 'Yank line to system clipboard' })

-- Delete to black hole register
vim.keymap.set({ 'n', 'v' }, '<leader>d', '"_d', { desc = 'Delete to black hole' })
-- Change to black hole register
vim.keymap.set({ 'n', 'v' }, '<leader>cc', '"_c', { desc = 'Change (Black hole)' })

-- Disable Q (ex mode)
vim.keymap.set('n', 'Q', '<nop>')

-- Quick substitution for word under cursor
vim.keymap.set('n', '<leader>S', [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], {
  desc = '[S]ubstitute word under cursor',
})

-- Make file executable
vim.keymap.set('n', '<leader>x', '<cmd>!chmod +x %<CR>', { silent = true, desc = 'Make file executable' })

-- Go-specific error handling templates (only useful for Go development)
vim.keymap.set('n', '<leader>ge', 'oif err != nil {<CR>}<Esc>Oreturn err<Esc>', { desc = '[G]o [E]rror return' })
vim.keymap.set('n', '<leader>ga', 'oassert.NoError(err, "")<Esc>F";a', { desc = '[G]o [A]ssert no error' })
vim.keymap.set('n', '<leader>gf', 'oif err != nil {<CR>}<Esc>Olog.Fatalf("error: %s\\n", err.Error())<Esc>jj', { desc = '[G]o Error [F]atalf' })
vim.keymap.set('n', '<leader>gl', 'oif err != nil {<CR>}<Esc>O.logger.Error("error", "error", err)<Esc>F.;i', { desc = '[G]o Error [L]ogger' })

-- Quickfix and location list navigation
vim.keymap.set('n', '[q', '<cmd>cprev<CR>zz', { desc = 'Previous quickfix' })
vim.keymap.set('n', ']q', '<cmd>cnext<CR>zz', { desc = 'Next quickfix' })
vim.keymap.set('n', '[l', '<cmd>lprev<CR>zz', { desc = 'Previous location' })

vim.keymap.set('n', ']l', '<cmd>lnext<CR>zz', { desc = 'Next location' })

-- NvChad Theme Switcher
vim.keymap.set('n', '<leader>th', ':Telescope themes<CR>', { desc = 'NvChad [Th]eme Switcher' })

-- AI tools quick toggles (sidekick / avante)
do
  local ai_toggle = require 'custom.ai_tools_toggle'
  ai_toggle.setup()

  vim.keymap.set('n', '<leader>ta', function()
    ai_toggle.toggle 'all'
  end, { desc = '[T]oggle [A]I tools (all)' })

  vim.keymap.set('n', '<leader>ts', function()
    ai_toggle.toggle 'sidekick'
  end, { desc = '[T]oggle [S]idekick' })

  vim.keymap.set('n', '<leader>tv', function()
    ai_toggle.toggle 'avante'
  end, { desc = '[T]oggle A[v]ante' })
end

-- Subtle beacon for large jumps (e.g. 22j / 33k / G), so landing line is easy to confirm.
do
  local api = vim.api
  local uv = vim.uv or vim.loop
  local ns = api.nvim_create_namespace 'JumpCursorBeacon'
  local augroup = api.nvim_create_augroup('JumpCursorBeacon', { clear = true })

  local beacon_enabled = vim.g.jump_cursor_beacon_enabled ~= false
  local min_jump = vim.g.jump_cursor_beacon_min_distance or 8
  local strong_ms = vim.g.jump_cursor_beacon_strong_ms or 120
  local soft_ms = vim.g.jump_cursor_beacon_soft_ms or 220
  local cooldown_ms = vim.g.jump_cursor_beacon_cooldown_ms or 120

  local state = {
    last_line_by_win = {},
    last_pulse_at_by_win = {},
    pulse_id_by_win = {},
  }

  local function beacon_palette()
    return {
      JumpCursorBeaconStrong = { bg = '#ffcc00' },
      JumpCursorBeaconSoft = { bg = '#b26a00' },
    }
  end

  local function apply_beacon_highlights()
    for group, spec in pairs(beacon_palette()) do
      api.nvim_set_hl(0, group, spec)
    end
  end

  local function same_position(winid, bufnr, lnum)
    return api.nvim_win_is_valid(winid) and api.nvim_win_get_buf(winid) == bufnr and api.nvim_win_get_cursor(winid)[1] == lnum
  end

  local function set_line_beacon(bufnr, lnum, hl_group)
    api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
    api.nvim_buf_set_extmark(bufnr, ns, lnum - 1, 0, {
      line_hl_group = hl_group,
      priority = 220,
    })
  end

  local function clear_line_beacon(bufnr)
    if api.nvim_buf_is_valid(bufnr) then
      api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
    end
  end

  local function pulse_jump_line(winid, bufnr, lnum)
    local pulse_id = (state.pulse_id_by_win[winid] or 0) + 1
    state.pulse_id_by_win[winid] = pulse_id

    set_line_beacon(bufnr, lnum, 'JumpCursorBeaconStrong')

    vim.defer_fn(function()
      if state.pulse_id_by_win[winid] ~= pulse_id then
        return
      end

      if not same_position(winid, bufnr, lnum) then
        clear_line_beacon(bufnr)
        return
      end

      set_line_beacon(bufnr, lnum, 'JumpCursorBeaconSoft')

      vim.defer_fn(function()
        if state.pulse_id_by_win[winid] ~= pulse_id then
          return
        end
        clear_line_beacon(bufnr)
      end, soft_ms)
    end, strong_ms)
  end

  local function pulse_current_line(opts)
    opts = opts or {}

    if not opts.force and not beacon_enabled then
      return false
    end

    local winid = api.nvim_get_current_win()
    local bufnr = api.nvim_win_get_buf(winid)

    if vim.bo[bufnr].buftype ~= '' then
      return false
    end

    local lnum = api.nvim_win_get_cursor(winid)[1]
    state.last_line_by_win[winid] = lnum
    pulse_jump_line(winid, bufnr, lnum)
    return true
  end

  local function repeat_search(motion)
    local winid = api.nvim_get_current_win()
    local before = api.nvim_win_get_cursor(winid)
    vim.cmd.normal {
      bang = true,
      args = { tostring(vim.v.count1) .. motion },
    }

    local after = api.nvim_win_get_cursor(winid)
    if after[1] ~= before[1] or after[2] ~= before[2] then
      pulse_current_line()
    end
  end

  vim.keymap.set('n', 'n', function()
    repeat_search 'n'
  end, { desc = 'Next search result' })

  vim.keymap.set('n', 'N', function()
    repeat_search 'N'
  end, { desc = 'Previous search result' })

  vim.keymap.set('n', '<leader>tc', function()
    pulse_current_line { force = true }
  end, { desc = '[T]rack [C]ursor' })

  api.nvim_create_autocmd('CursorMoved', {
    group = augroup,
    callback = function()
      local mode = vim.fn.mode(1)
      if not beacon_enabled or mode:sub(1, 1) ~= 'n' then
        return
      end

      local winid = api.nvim_get_current_win()
      local bufnr = api.nvim_win_get_buf(winid)
      local lnum = api.nvim_win_get_cursor(winid)[1]

      if vim.bo[bufnr].buftype ~= '' then
        state.last_line_by_win[winid] = lnum
        return
      end

      local prev = state.last_line_by_win[winid]
      state.last_line_by_win[winid] = lnum

      if not prev or math.abs(lnum - prev) < min_jump then
        return
      end

      local now_ms = (uv and uv.now and uv.now()) or 0
      local last_ms = state.last_pulse_at_by_win[winid] or 0
      if now_ms - last_ms < cooldown_ms then
        return
      end

      state.last_pulse_at_by_win[winid] = now_ms
      pulse_jump_line(winid, bufnr, lnum)
    end,
  })

  api.nvim_create_autocmd({ 'BufEnter', 'WinEnter' }, {
    group = augroup,
    callback = function()
      local winid = api.nvim_get_current_win()
      state.last_line_by_win[winid] = api.nvim_win_get_cursor(winid)[1]
    end,
  })

  api.nvim_create_autocmd('User', {
    group = augroup,
    pattern = 'JumpCursorBeaconPulse',
    callback = function()
      pulse_current_line()
    end,
  })

  api.nvim_create_autocmd('User', {
    group = augroup,
    pattern = 'NvThemeReload',
    callback = function()
      vim.schedule(apply_beacon_highlights)
    end,
  })

  api.nvim_create_autocmd('OptionSet', {
    group = augroup,
    pattern = 'background',
    callback = function()
      vim.schedule(apply_beacon_highlights)
    end,
  })

  api.nvim_create_autocmd({ 'ColorScheme', 'VimEnter' }, {
    group = augroup,
    callback = function()
      vim.schedule(apply_beacon_highlights)
    end,
  })

  apply_beacon_highlights()
end
