local theme = require 'custom.theme'

return {
  'f-person/auto-dark-mode.nvim',
  main = 'auto-dark-mode',
  dependencies = { 'NvChad/base46' },
  event = 'VimEnter',
  opts = {
    update_interval = 30000,
    set_dark_mode = function()
      theme.apply 'dark'
    end,
    set_light_mode = function()
      theme.apply 'light'
    end,
  },
}
