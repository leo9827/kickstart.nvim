local M = {}

function M.run(check)
  local ok, err = xpcall(check, debug.traceback)
  if not ok then
    vim.api.nvim_err_writeln(err)
    vim.cmd 'cquit'
  end
end

return M
