return {
  'Bekaboo/dropbar.nvim',
  lazy = true,
  event = { 'BufReadPost', 'BufNewFile' },
  config = function()
    require('dropbar').setup {
      bar = {
        enable = function(bufnr)
          return vim.bo[bufnr].buftype == '' and not require('custom.large_file').is_large(bufnr)
        end,
        attach_events = { 'BufReadPost', 'BufNewFile' },
      },
      icons = {
        enable = true,
        ui = {
          bar = {
            separator = ' 󰅂 ',
            extends = '…',
          },
          menu = {
            separator = ' ',
            indicator = ' 󰅂 ',
          },
        },
      },
      menu = {
        quick_navigation = true,
      },
      preview = {
        enable = true,
        max_width = 80,
        max_height = 20,
      },
    }

    local dropbar_api = require 'dropbar.api'
    vim.keymap.set('n', '<Leader>;', dropbar_api.pick, { desc = 'Pick symbols in winbar' })
    vim.keymap.set('n', '[;', dropbar_api.goto_context_start, { desc = 'Go to start of current context' })
    vim.keymap.set('n', '];', dropbar_api.select_next_context, { desc = 'Select next context' })
  end,
}
