local M = {}
local api = vim.api
local saved = {}
local max_bytes = 1024 * 1024

function M.is_large(bufnr)
  bufnr = bufnr == 0 and api.nvim_get_current_buf() or bufnr
  return api.nvim_buf_is_valid(bufnr) and vim.b[bufnr].large_file == true
end

local function detect(bufnr)
  if vim.b[bufnr].large_file_override ~= nil then
    return vim.b[bufnr].large_file_override
  end
  local size = vim.uv.fs_stat(api.nvim_buf_get_name(bufnr))
  if size and size.size >= max_bytes then
    return true
  end
  if not api.nvim_buf_is_loaded(bufnr) then
    return false
  end
  local count = api.nvim_buf_line_count(bufnr)
  if count >= 20000 or api.nvim_buf_get_offset(bufnr, count) >= max_bytes then
    return true
  end
  for start = 0, count - 1, 256 do
    for _, line in ipairs(api.nvim_buf_get_lines(bufnr, start, math.min(start + 256, count), false)) do
      if #line >= 2000 then
        return true
      end
    end
  end
  return false
end

local function update_breadcrumbs(bufnr, large, previous)
  if not package.loaded.dropbar then
    return
  end
  local bar = require 'dropbar.utils.bar'
  if large then
    bar.exec('del', { buf = bufnr })
  end
  for _, win in ipairs(vim.fn.win_findbuf(bufnr)) do
    if large and vim.wo[win].winbar:find('v:lua.dropbar', 1, true) then
      saved[bufnr].winbars[win] = vim.wo[win].winbar
      vim.wo[win].winbar = ''
    elseif not large and previous and vim.wo[win].winbar == '' then
      if previous.winbars[win] then
        vim.wo[win].winbar = previous.winbars[win]
      else
        bar.attach(bufnr, win)
      end
    end
  end
end

local function apply(bufnr)
  if not api.nvim_buf_is_valid(bufnr) or vim.bo[bufnr].buftype ~= '' then
    return
  end
  local large = M.is_large(bufnr)
  local previous = saved[bufnr]
  local mode_changed = large ~= (previous ~= nil)
  if large then
    saved[bufnr] = saved[bufnr]
      or {
        syntax = vim.bo[bufnr].syntax,
        indentexpr = vim.bo[bufnr].indentexpr,
        diagnostics = vim.diagnostic.is_enabled { bufnr = bufnr },
        winbars = {},
        rendering = package.loaded['render-markdown.state'] and require('render-markdown.state').get(bufnr).enabled,
      }
    pcall(vim.treesitter.stop, bufnr)
    vim.bo[bufnr].syntax = 'OFF'
    vim.bo[bufnr].indentexpr = ''
    vim.diagnostic.enable(false, { bufnr = bufnr })
    for _, client in ipairs(vim.lsp.get_clients { bufnr = bufnr }) do
      vim.lsp.buf_detach_client(bufnr, client.id)
    end
    if package.loaded.ufo then
      require('ufo').detach(bufnr)
    end
  elseif saved[bufnr] then
    saved[bufnr] = nil
    vim.bo[bufnr].syntax = previous.syntax
    vim.bo[bufnr].indentexpr = previous.indentexpr
    vim.diagnostic.enable(previous.diagnostics, { bufnr = bufnr })
    api.nvim_exec_autocmds('FileType', { buffer = bufnr, modeline = false })
    if package.loaded.ufo then
      require('ufo').attach(bufnr)
    end
  end
  if package.loaded.ibl then
    require('ibl').refresh(bufnr)
  end
  local restore_markdown = previous and previous.rendering
  if package.loaded['render-markdown'] and (large or restore_markdown) then
    api.nvim_buf_call(bufnr, function()
      require('render-markdown').set_buf(not large)
    end)
  end
  update_breadcrumbs(bufnr, large, previous)
  if mode_changed and package.loaded['treesitter-context'] then
    local context = require 'treesitter-context'
    if context.enabled() then
      context.enable()
    end
  end
  vim.cmd.redrawstatus()
end

function M.toggle()
  local bufnr = api.nvim_get_current_buf()
  if vim.bo[bufnr].buftype ~= '' then
    return
  end
  vim.b[bufnr].large_file_override = not M.is_large(bufnr)
  vim.b[bufnr].large_file = vim.b[bufnr].large_file_override
  apply(bufnr)
  vim.notify('Light mode ' .. (M.is_large(bufnr) and 'on' or 'off') .. ' for this file', vim.log.levels.INFO)
end

function M.setup()
  local group = api.nvim_create_augroup('large-file-mode', { clear = true })
  api.nvim_create_autocmd({ 'BufReadPre', 'BufReadPost', 'BufWritePost', 'FileType' }, {
    group = group,
    callback = function(event)
      if vim.bo[event.buf].buftype ~= '' then
        return
      end
      local previous = M.is_large(event.buf)
      vim.b[event.buf].large_file = detect(event.buf)
      if previous or M.is_large(event.buf) then
        apply(event.buf)
        vim.schedule(function()
          if M.is_large(event.buf) then
            apply(event.buf)
          end
        end)
      end
    end,
  })
  api.nvim_create_autocmd('LspAttach', {
    group = group,
    callback = function(event)
      if M.is_large(event.buf) then
        vim.schedule(function()
          if api.nvim_buf_is_valid(event.buf) then
            vim.lsp.buf_detach_client(event.buf, event.data.client_id)
          end
        end)
      end
    end,
  })
  api.nvim_create_autocmd('BufWipeout', {
    group = group,
    callback = function(event)
      saved[event.buf] = nil
    end,
  })
  vim.keymap.set('n', '<leader>tl', M.toggle, { desc = 'Toggle file light mode' })
end

return M
