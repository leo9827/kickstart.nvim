return {
  'rebelot/kanagawa.nvim',
  name = 'kanagawa',
  lazy = true, -- Lazy load since not currently active
  config = function()
    -- vim.cmd("colorscheme rose-pine")
    require('kanagawa').setup {
      transparent = false, -- do not set background color
    }
  end,
}
