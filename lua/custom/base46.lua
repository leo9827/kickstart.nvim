return {
  'NvChad/base46',
  lazy = false,
  priority = 1000,
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()
    require('custom.theme').setup()
  end,
}
