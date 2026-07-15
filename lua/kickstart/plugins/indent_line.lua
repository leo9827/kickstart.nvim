return {
  { -- Add indentation guides even on blank lines
    'lukas-reineke/indent-blankline.nvim',
    event = { 'BufReadPost', 'BufNewFile' },
    -- Enable `lukas-reineke/indent-blankline.nvim`
    -- See `:help ibl`
    main = 'ibl',
    opts = {
      indent = { char = '│', tab_char = '│' },
      scope = { enabled = true, show_start = false, show_end = false },
      exclude = {
        filetypes = { 'help', 'neo-tree', 'lazy', 'dashboard', 'alpha', 'Trouble', 'trouble', 'gitcommit' },
        buftypes = { 'terminal', 'nofile' },
      },
    },
  },
}
