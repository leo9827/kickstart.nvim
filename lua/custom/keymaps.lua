vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv", { desc = 'Move line down' })
vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv", { desc = 'Move line up' })
vim.keymap.set('n', 'J', 'mzJ`z', { desc = 'Join lines' })
vim.keymap.set('n', '=ap', "ma=ap'a", { desc = 'Format paragraph' })

vim.keymap.set('x', '<leader>p', [["_dP]], { desc = 'Paste without yanking' })
vim.keymap.set({ 'n', 'v' }, '<leader>y', [["+y]], { desc = 'Yank to system clipboard' })
vim.keymap.set('n', '<leader>Y', [["+Y]], { desc = 'Yank line to system clipboard' })
vim.keymap.set({ 'n', 'v' }, '<leader>d', '"_d', { desc = 'Delete without yanking' })
vim.keymap.set({ 'n', 'v' }, '<leader>cc', '"_c', { desc = 'Change without yanking' })

vim.keymap.set('n', 'Q', '<nop>')
vim.keymap.set('n', '<leader>S', [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], {
  desc = 'Substitute word under cursor',
})
vim.keymap.set('n', '<leader>cx', '<cmd>!chmod +x %<CR>', { silent = true, desc = 'Make file executable' })

vim.keymap.set('n', '[q', '<cmd>cprev<CR>zz', { desc = 'Previous quickfix' })
vim.keymap.set('n', ']q', '<cmd>cnext<CR>zz', { desc = 'Next quickfix' })
vim.keymap.set('n', '[l', '<cmd>lprev<CR>zz', { desc = 'Previous location' })
vim.keymap.set('n', ']l', '<cmd>lnext<CR>zz', { desc = 'Next location' })

vim.keymap.set('n', '<leader>gs', '<cmd>Telescope git_status<CR>', { desc = 'Git status' })
vim.keymap.set('n', '<leader>th', require('custom.theme').toggle, { desc = 'Toggle light/dark theme' })

require('custom.jump_beacon').setup()
