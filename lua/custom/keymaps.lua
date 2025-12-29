-- Custom keymaps extracted from remap.lua
-- Only keep non-conflicting, useful keymaps

-- Visual mode: move lines up/down
vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv", { desc = 'Move line down' })
vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv", { desc = 'Move line up' })

-- Keep cursor centered when joining lines
vim.keymap.set('n', 'J', 'mzJ`z', { desc = 'Join lines (cursor centered)' })

-- Keep cursor centered when scrolling
vim.keymap.set('n', '<C-d>', '<C-d>zz', { desc = 'Scroll down (centered)' })
vim.keymap.set('n', '<C-u>', '<C-u>zz', { desc = 'Scroll up (centered)' })

-- Keep search centered
vim.keymap.set('n', 'n', 'nzzzv', { desc = 'Next search (centered)' })
vim.keymap.set('n', 'N', 'Nzzzv', { desc = 'Previous search (centered)' })

-- Format paragraph and return to position
vim.keymap.set('n', '=ap', "ma=ap'a", { desc = 'Format paragraph' })

-- Better paste in visual mode (don't yank replaced text)
vim.keymap.set('x', '<leader>p', [["_dP]], { desc = 'Paste without yanking' })

-- System clipboard operations
vim.keymap.set({ 'n', 'v' }, '<leader>y', [["+y]], { desc = 'Yank to system clipboard' })
vim.keymap.set('n', '<leader>Y', [["+Y]], { desc = 'Yank line to system clipboard' })

-- Delete to black hole register
vim.keymap.set({ 'n', 'v' }, '<leader>d', '"_d', { desc = 'Delete to black hole' })

-- Disable Q (ex mode)
vim.keymap.set('n', 'Q', '<nop>')

-- Quick substitution for word under cursor
vim.keymap.set('n', '<leader>S', [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = '[S]ubstitute word under cursor' })

-- Make file executable
vim.keymap.set('n', '<leader>x', '<cmd>!chmod +x %<CR>', { silent = true, desc = 'Make file executable' })

-- Go-specific error handling templates (only useful for Go development)
vim.keymap.set('n', '<leader>ge', 'oif err != nil {<CR>}<Esc>Oreturn err<Esc>', { desc = '[G]o [E]rror return' })
vim.keymap.set('n', '<leader>ga', 'oassert.NoError(err, "")<Esc>F";a', { desc = '[G]o [A]ssert no error' })
vim.keymap.set('n', '<leader>gf', 'oif err != nil {<CR>}<Esc>Olog.Fatalf("error: %s\\n", err.Error())<Esc>jj', { desc = '[G]o Error [F]atalf' })
vim.keymap.set('n', '<leader>gl', 'oif err != nil {<CR>}<Esc>O.logger.Error("error", "error", err)<Esc>F.;i', { desc = '[G]o Error [L]ogger' })

-- Quickfix and location list navigation
vim.keymap.set('n', '[q', '<cmd>cprev<CR>zz', { desc = 'Previous quickfix' })
vim.keymap.set('n', ']q', '<cmd>cnext<CR>zz', { desc = 'Next quickfix' })
vim.keymap.set('n', '[l', '<cmd>lprev<CR>zz', { desc = 'Previous location' })
vim.keymap.set('n', ']l', '<cmd>lnext<CR>zz', { desc = 'Next location' })
