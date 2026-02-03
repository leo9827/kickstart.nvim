local M = {}

---@param bufnr integer
---@param line1 integer 1-based
---@param line2 integer 1-based
---@return string|nil
function M.from_range(bufnr, line1, line2)
  if not bufnr or bufnr == 0 then return nil end
  if not vim.api.nvim_buf_is_valid(bufnr) then return nil end
  if not line1 or not line2 then return nil end

  local start_idx = math.max(0, line1 - 1)
  local end_idx = math.max(start_idx, line2)
  local lines = vim.api.nvim_buf_get_lines(bufnr, start_idx, end_idx, false)
  if not lines or #lines == 0 then return nil end
  return table.concat(lines, "\n")
end

---@param bufnr integer
---@return string|nil
function M.from_visual(bufnr)
  if not bufnr or bufnr == 0 then return nil end
  if not vim.api.nvim_buf_is_valid(bufnr) then return nil end

  local mode = vim.fn.mode()

  local start_pos
  local end_pos

  -- In visual mode, '< and '> are not guaranteed to be set yet, so use 'v and '.'
  if mode == "v" or mode == "V" or mode == "\22" then
    start_pos = vim.fn.getpos("v")
    end_pos = vim.fn.getpos(".")
  else
    mode = vim.fn.visualmode()
    start_pos = vim.fn.getpos("'<")
    end_pos = vim.fn.getpos("'>")
  end

  if start_pos[2] == 0 or end_pos[2] == 0 then return nil end
  local start_row = start_pos[2] - 1
  local start_col = start_pos[3] - 1
  local end_row = end_pos[2] - 1
  local end_col = end_pos[3] - 1

  if start_row > end_row or (start_row == end_row and start_col > end_col) then
    start_row, end_row = end_row, start_row
    start_col, end_col = end_col, start_col
  end

  if mode == "V" then
    local lines = vim.api.nvim_buf_get_lines(bufnr, start_row, end_row + 1, false)
    if not lines or #lines == 0 then return nil end
    return table.concat(lines, "\n")
  end

  local end_line = vim.api.nvim_buf_get_lines(bufnr, end_row, end_row + 1, false)[1] or ""
  end_col = math.min(end_col + 1, #end_line)

  local ok, text = pcall(vim.api.nvim_buf_get_text, bufnr, start_row, start_col, end_row, end_col, {})
  if not ok or not text or #text == 0 then return nil end
  return table.concat(text, "\n")
end

return M
