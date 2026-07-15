return {
  'stevearc/aerial.nvim',
  cmd = { 'AerialToggle', 'AerialOpen', 'AerialClose', 'AerialNav', 'AerialGo' },
  keys = {
    { '<leader>o', '<cmd>AerialToggle<CR>', desc = 'Toggle outline viewer' },
    { '<leader>so', '<cmd>Telescope aerial<CR>', desc = 'Search outline' },
  },
  dependencies = {
    'nvim-treesitter/nvim-treesitter',
    'nvim-tree/nvim-web-devicons',
    'nvim-telescope/telescope.nvim',
  },
  opts = {
    layout = {
      max_width = { 48, 0.25 },
      min_width = 24,
    },
    show_guides = true,
    highlight_on_hover = true,
  },
  config = function(_, opts)
    require('aerial').setup(opts)
    pcall(require('telescope').load_extension, 'aerial')
  end,
}
