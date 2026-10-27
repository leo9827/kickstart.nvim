local M = {}
local api = vim.api

function M.copy(diagnostics)
  local mode = vim.fn.mode()
  local first, last, lines
  if mode == 'v' or mode == 'V' or mode == '\22' then
    local a, b = vim.fn.getpos 'v', vim.fn.getpos '.'
    local opts = { type = mode, exclusive = vim.o.selection == 'exclusive' }
    local region = vim.fn.getregionpos(a, b, opts)
    first, last = region[1][1][2], region[#region][2][2]
    lines = vim.fn.getregion(a, b, opts)
  else
    first = api.nvim_win_get_cursor(0)[1]
    last, lines = first, { api.nvim_get_current_line() }
  end
  local path = api.nvim_buf_get_name(0)
  local root = vim.fs.root(0, { '.git', 'go.mod', 'package.json' }) or vim.fn.getcwd()
  local relative = path ~= '' and (vim.fs.relpath(root, path) or path) or '[No Name]'
  local fence = '```'
  for ticks in table.concat(lines, '\n'):gmatch '`+' do
    if #ticks >= #fence then
      fence = string.rep('`', #ticks + 1)
    end
  end
  local result = { ('%s:%d-%d'):format(relative, first, last), '', fence .. vim.bo.filetype }
  vim.list_extend(result, lines)
  result[#result + 1] = fence
  if diagnostics then
    local found = vim.diagnostic.get(0)
    table.sort(found, function(a, b)
      return a.lnum < b.lnum
    end)
    for _, diagnostic in ipairs(found) do
      if diagnostic.lnum < last and (diagnostic.end_lnum or diagnostic.lnum) >= first - 1 then
        result[#result + 1] = ('- Line %d [%s]: %s'):format(
          diagnostic.lnum + 1,
          vim.diagnostic.severity[diagnostic.severity],
          diagnostic.message:gsub('\n', ' ')
        )
      end
    end
  end
  vim.fn.setreg('+', table.concat(result, '\n'), 'v')
  vim.notify('Copied code with source' .. (diagnostics and ' and diagnostics' or ''))
end

function M.setup()
  vim.keymap.set({ 'n', 'x' }, '<leader>cy', function()
    M.copy(false)
  end, { desc = 'Copy code with source' })
  vim.keymap.set({ 'n', 'x' }, '<leader>cY', function()
    M.copy(true)
  end, { desc = 'Copy code with source and diagnostics' })
end

return M
