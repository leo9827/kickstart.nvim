return {
  'kepano/flexoki-neovim',
  name = 'flexoki',
  priority = 1000, -- Load this theme first (currently active)
  lazy = false, -- Load immediately since it's the active theme
  config = function()
    -- vim.api.nvim_set_option_value('background', 'light', {})
  end,
}
