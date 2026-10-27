local M = {}
local api = vim.api
local tickets = {}
local ns = api.nvim_create_namespace 'ReturnTicket'

local function clear(tab)
  local ticket = tickets[tab]
  if ticket and api.nvim_buf_is_valid(ticket.buf) then
    pcall(api.nvim_buf_del_extmark, ticket.buf, ns, ticket.mark)
  end
  tickets[tab] = nil
end

function M.save()
  if vim.bo.buftype ~= '' then
    return
  end
  local tab, buf = api.nvim_get_current_tabpage(), api.nvim_get_current_buf()
  clear(tab)
  local pos = api.nvim_win_get_cursor(0)
  tickets[tab] = {
    buf = buf,
    win = api.nvim_get_current_win(),
    view = vim.fn.winsaveview(),
    mark = api.nvim_buf_set_extmark(buf, ns, pos[1] - 1, pos[2], {}),
  }
  vim.notify 'Return ticket saved · Space mr to return'
end

function M.restore()
  local tab = api.nvim_get_current_tabpage()
  local ticket = tickets[tab]
  if not ticket or not api.nvim_buf_is_loaded(ticket.buf) then
    clear(tab)
    vim.notify 'No return ticket in this tab'
    return
  end
  local pos = api.nvim_buf_get_extmark_by_id(ticket.buf, ns, ticket.mark, {})
  if #pos == 0 then
    clear(tab)
    vim.notify 'Return position is no longer available'
    return
  end
  if api.nvim_win_is_valid(ticket.win) then
    api.nvim_set_current_win(ticket.win)
  end
  api.nvim_win_set_buf(0, ticket.buf)
  local view = vim.deepcopy(ticket.view)
  local line_shift = pos[1] + 1 - view.lnum
  view.topline = math.max(1, view.topline + line_shift)
  view.lnum, view.col = pos[1] + 1, pos[2]
  vim.fn.winrestview(view)
  require('custom.jump_beacon').pulse()
end

function M.setup()
  api.nvim_create_autocmd('TabClosed', {
    group = api.nvim_create_augroup('return-ticket', { clear = true }),
    callback = function()
      for tab in pairs(tickets) do
        if not api.nvim_tabpage_is_valid(tab) then
          clear(tab)
        end
      end
    end,
  })
  vim.keymap.set('n', '<leader>mb', M.save, { desc = 'Bookmark return ticket' })
  vim.keymap.set('n', '<leader>mr', M.restore, { desc = 'Return to editing ticket' })
end

return M
