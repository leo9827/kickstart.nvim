return {
  'stevearc/aerial.nvim',
  opts = {},
  -- Optional dependencies
  dependencies = {
    'nvim-treesitter/nvim-treesitter',
    'nvim-tree/nvim-web-devicons',
  },
  config = function()
    require('aerial').setup {
      placement = 'right',
      width = 30,
      -- 是否显示导航箭头
      show_guides = true,
    }
    -- keymaps
    vim.keymap.set('n', '<leader>al', '<cmd>AerialToggle<CR>', { desc = 'Toggle Aerial(outline viewer)' })
    vim.keymap.set('n', '<leader>sa', '<cmd>Telescope aerial<CR>', { desc = 'Search AerialSymbols' })
  end,
}
