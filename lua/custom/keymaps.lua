-- Custom keymaps extracted from remap.lua
-- Only keep non-conflicting, useful keymaps
local function smooth_half_page(direction)
  local lines = math.max(math.floor(vim.api.nvim_win_get_height(0) / 2), 1)
  local duration = 120
  local ok, neoscroll = pcall(require, 'neoscroll')

  if ok then
    neoscroll.scroll(direction * lines, { move_cursor = true, duration = duration, easing = 'sine' })
    vim.defer_fn(function()
      pcall(vim.cmd, 'normal! zz')
    end, duration)
  else
    if direction > 0 then
      vim.cmd 'normal! <C-d>'
    else
      vim.cmd 'normal! <C-u>'
    end
    vim.cmd 'normal! zz'
  end
end

-- Visual mode: move lines up/down
vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv", { desc = 'Move line down' })
vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv", { desc = 'Move line up' })

-- Keep cursor centered when joining lines
vim.keymap.set('n', 'J', 'mzJ`z', { desc = 'Join lines (cursor centered)' })

-- Keep cursor centered when scrolling
vim.keymap.set('n', '<C-d>', function()
  smooth_half_page(1)
end, { desc = 'Scroll down (centered)' })
vim.keymap.set('n', '<C-u>', function()
  smooth_half_page(-1)
end, { desc = 'Scroll up (centered)' })

-- Format paragraph and return to position
vim.keymap.set('n', '=ap', "ma=ap'a", { desc = 'Format paragraph' })

-- Better paste in visual mode (don't yank replaced text)
vim.keymap.set('x', '<leader>p', [["_dP]], { desc = 'Paste without yanking' })

-- System clipboard operations
vim.keymap.set({ 'n', 'v' }, '<leader>y', [["+y]], { desc = 'Yank to system clipboard' })
vim.keymap.set('n', '<leader>Y', [["+Y]], { desc = 'Yank line to system clipboard' })

-- Delete to black hole register
vim.keymap.set({ 'n', 'v' }, '<leader>d', '"_d', { desc = 'Delete to black hole' })
-- Change to black hole register
vim.keymap.set({ 'n', 'v' }, '<leader>c', '"_c', { desc = 'Change to black hole' })

-- Disable Q (ex mode)
vim.keymap.set('n', 'Q', '<nop>')

-- Quick substitution for word under cursor
vim.keymap.set('n', '<leader>S', [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], {
  desc = '[S]ubstitute word under cursor',
})

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

-- NvChad Theme Switcher
vim.keymap.set('n', '<leader>th', ':Telescope themes<CR>', { desc = 'NvChad [Th]eme Switcher' })
