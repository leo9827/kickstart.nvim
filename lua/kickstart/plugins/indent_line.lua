return {
  { -- Add indentation guides even on blank lines
    'lukas-reineke/indent-blankline.nvim',
    event = { 'BufReadPost', 'BufNewFile' },
    -- Enable `lukas-reineke/indent-blankline.nvim`
    -- See `:help ibl`
    main = 'ibl',
    config = function(_, opts)
      local hooks = require 'ibl.hooks'
      hooks.register(hooks.type.ACTIVE, function(bufnr)
        return not require('custom.large_file').is_large(bufnr)
      end)
      require('ibl').setup(opts)
    end,
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
