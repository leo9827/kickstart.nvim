local M = {}

---@class AvanteLiteSidebarState
---@field bufnr integer?
---@field winid integer?
---@field code_winid integer?
local state = {
  bufnr = nil,
  winid = nil,
  code_winid = nil,
}

local function buf_valid(bufnr) return bufnr ~= nil and bufnr ~= 0 and vim.api.nvim_buf_is_valid(bufnr) end
local function win_valid(winid) return winid ~= nil and winid ~= 0 and vim.api.nvim_win_is_valid(winid) end

---@param cfg table
---@return integer bufnr
local function ensure_buf(cfg)
  if buf_valid(state.bufnr) then return state.bufnr end

  local bufnr = vim.api.nvim_create_buf(false, true)
  state.bufnr = bufnr

  vim.api.nvim_buf_set_name(bufnr, cfg.ui.buffer_name)
  vim.bo[bufnr].buftype = "nofile"
  vim.bo[bufnr].bufhidden = "hide"
  vim.bo[bufnr].swapfile = false
  vim.bo[bufnr].modifiable = false
  vim.bo[bufnr].filetype = cfg.ui.filetype

  return bufnr
end

---@param cfg table
---@return integer winid
function M.open(cfg)
  local bufnr = ensure_buf(cfg)

  if win_valid(state.winid) then
    pcall(vim.api.nvim_win_set_width, state.winid, cfg.ui.width)
    if vim.api.nvim_win_get_buf(state.winid) ~= bufnr then vim.api.nvim_win_set_buf(state.winid, bufnr) end
    return state.winid
  end

  state.code_winid = vim.api.nvim_get_current_win()

  if cfg.ui.position == "left" then
    vim.cmd("topleft vsplit")
  else
    vim.cmd("botright vsplit")
  end

  local winid = vim.api.nvim_get_current_win()
  state.winid = winid
  vim.api.nvim_win_set_buf(winid, bufnr)
  pcall(vim.api.nvim_win_set_width, winid, cfg.ui.width)

  vim.wo[winid].number = false
  vim.wo[winid].relativenumber = false
  vim.wo[winid].wrap = true
  vim.wo[winid].cursorline = false

  return winid
end

function M.is_open() return win_valid(state.winid) end

function M.focus()
  if not win_valid(state.winid) then return end
  vim.api.nvim_set_current_win(state.winid)
end

function M.back_to_code()
  if not win_valid(state.code_winid) then return end
  vim.api.nvim_set_current_win(state.code_winid)
end

---@param lines string[]
function M.append(lines)
  if not buf_valid(state.bufnr) then return end
  local bufnr = state.bufnr

  -- Filter empty trailing line from job callbacks.
  local out = {}
  for _, line in ipairs(lines or {}) do
    if line ~= nil then table.insert(out, line) end
  end
  if #out == 0 then return end

  vim.bo[bufnr].modifiable = true
  vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, out)
  vim.bo[bufnr].modifiable = false
end

function M.clear()
  if not buf_valid(state.bufnr) then return end
  local bufnr = state.bufnr
  vim.bo[bufnr].modifiable = true
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {})
  vim.bo[bufnr].modifiable = false
end

function M.close()
  if win_valid(state.winid) then pcall(vim.api.nvim_win_close, state.winid, true) end
  state.winid = nil
end

return M
