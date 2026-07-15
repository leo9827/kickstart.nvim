return {
  'stevearc/dressing.nvim',
  event = 'VeryLazy', -- Lazy load to improve startup time
  config = function()
    require('dressing').setup {
      input = {
        relative = 'cursor',
        anchor = 'NW',
        border = 'rounded',
        winblend = 5,
        max_width = 80,
      },
      select = {
        enabled = true,
        backend = { 'builtin' },
        builtin = {
          relative = 'cursor',
          anchor = 'NW',
          border = 'rounded',
          winblend = 5,
        },
      },
    }
  end,
}
