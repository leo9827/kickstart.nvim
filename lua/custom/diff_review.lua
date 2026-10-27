local M = {}

-- Both sides are immutable snapshots; closing the tab never writes a source file.
function M.open(before, after, filetype, titles)
  local function fill(lines, title)
    vim.bo.buftype = 'nofile'
    vim.bo.bufhidden = 'wipe'
    vim.bo.swapfile = false
    vim.bo.buflisted = false
    vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
    vim.bo.filetype = filetype
    vim.bo.modifiable = false
    vim.bo.modified = false
    vim.wo.winbar = ' ' .. title:gsub('%%', '%%%%')
    vim.cmd.diffthis()
    vim.keymap.set('n', 'q', '<cmd>tabclose<CR>', { buffer = true, desc = 'Close comparison' })
  end
  vim.cmd.tabnew()
  fill(before, titles[1])
  vim.cmd.vnew()
  fill(after, titles[2])
end

return M
