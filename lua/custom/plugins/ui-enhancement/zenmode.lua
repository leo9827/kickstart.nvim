return {
  'Pocco81/true-zen.nvim',
  event = 'VeryLazy',
  opts = {
    -- add any options here
  },
  config = function()
    -- Normal mode: Narrow to the current region/function
    vim.keymap.set('n', '<leader>zn', ':TZNarrow<CR>', { desc = 'Narrow Region' })

    -- Visual mode: Narrow to the specifically selected text
    vim.keymap.set('v', '<leader>zn', ":'<,'>TZNarrow<CR>", { desc = 'Narrow Selection' })

    -- Focus mode: Maximizes the current window
    vim.keymap.set('n', '<leader>zf', ':TZFocus<CR>', { desc = 'Focus Window' })

    -- Minimalist mode: Hides UI elements (numbers, statusline, etc.)
    vim.keymap.set('n', '<leader>zm', ':TZMinimalist<CR>', { desc = 'Toggle Minimalist Mode' })

    -- Ataraxis mode: The full "Zen" experience (centered buffer)
    vim.keymap.set('n', '<leader>za', ':TZAtaraxis<CR>', { desc = 'Toggle Ataraxis (Zen Mode)' })
  end,
}
