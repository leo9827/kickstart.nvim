local M = {}

local patched = false

function M.patch()
  if patched or vim.fn.has 'nvim-0.12' == 0 then
    return
  end

  local codelens = vim.lsp and vim.lsp.codelens
  if type(codelens) ~= 'table' or type(codelens.enable) ~= 'function' then
    return
  end

  -- Keep older plugins working on Neovim 0.12+ without touching plugin source.
  codelens.refresh = function(opts)
    if opts ~= nil and type(opts) ~= 'table' then
      error('vim.lsp.codelens.refresh opts must be a table', 2)
    end

    local filter = {}
    if opts and opts.bufnr ~= nil then
      filter.bufnr = opts.bufnr
    end
    if opts and opts.client_id ~= nil then
      filter.client_id = opts.client_id
    end

    codelens.enable(true, filter)
  end

  codelens.clear = function(client_id, bufnr)
    local filter = {}
    if bufnr ~= nil then
      filter.bufnr = bufnr
    end
    if client_id ~= nil then
      filter.client_id = client_id
    end

    codelens.enable(false, filter)
  end

  patched = true
end

return M
