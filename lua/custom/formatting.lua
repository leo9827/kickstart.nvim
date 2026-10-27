local M = {}
local last_error = {}

local function feedback(bufnr)
  return function(err)
    if not vim.api.nvim_buf_is_valid(bufnr) then
      return
    end
    if not err then
      last_error[bufnr] = nil
      return
    end
    if last_error[bufnr] == err then
      return
    end
    last_error[bufnr] = err
    local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ':t')
    vim.schedule(function()
      vim.notify(('Format failed: %s\n%s\nSee :ConformInfo'):format(name, err), vim.log.levels.WARN, { title = 'Formatting' })
    end)
  end
end

function M.on_save(bufnr)
  local filetype = vim.bo[bufnr].filetype
  local unsupported_style = filetype == 'c' or filetype == 'cpp'
  if vim.b[bufnr].autoformat_disabled or vim.b[bufnr].large_file or unsupported_style then
    return
  end
  local has_formatter = #require('conform').list_formatters_for_buffer(bufnr) > 0
  local has_lsp_formatter = #vim.lsp.get_clients { bufnr = bufnr, method = 'textDocument/formatting' } > 0
  if not has_formatter and not has_lsp_formatter then
    return
  end
  return {
    timeout_ms = filetype == 'go' and 2000 or 500,
    lsp_format = 'fallback',
    quiet = true,
  }, feedback(bufnr)
end

function M.format()
  local bufnr = vim.api.nvim_get_current_buf()
  require('conform').format({ async = true, lsp_format = 'fallback', quiet = true }, feedback(bufnr))
end

function M.toggle()
  vim.b.autoformat_disabled = not vim.b.autoformat_disabled
  vim.notify('Autoformat ' .. (vim.b.autoformat_disabled and 'off' or 'on') .. ' for this file', vim.log.levels.INFO)
  vim.cmd.redrawstatus()
end

vim.api.nvim_create_autocmd('BufWipeout', {
  group = vim.api.nvim_create_augroup('format-feedback', { clear = true }),
  callback = function(event)
    last_error[event.buf] = nil
  end,
})

return M
