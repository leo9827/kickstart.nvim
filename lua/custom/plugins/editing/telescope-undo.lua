return {
  'debugloop/telescope-undo.nvim',
  dependencies = { 'nvim-telescope/telescope.nvim' },
  keys = {
    { '<leader>u', '<cmd>Telescope undo<CR>', desc = 'Search undo history' },
  },
  opts = {
    extensions = {
      undo = {},
    },
  },
  config = function(_, opts)
    require('telescope').setup(opts)
    require('telescope').load_extension 'undo'
  end,
}
