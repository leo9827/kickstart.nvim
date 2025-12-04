return {
  'rebelot/kanagawa.nvim',
  name = 'kanagawa',
  config = function()
    -- vim.cmd("colorscheme rose-pine")
    require('kanagawa').setup {
      transparent = false, -- do not set background color
    }
  end,
}
