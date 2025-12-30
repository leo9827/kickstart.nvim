return {
  -- 'joshdick/onedark.vim', -- for vim / neovim<0.5
  'navarasu/onedark.nvim',
  lazy = true, -- Lazy load since not currently active
  config = function()
    -- require('onedark').setup {
    -- 'dark', 'darker', 'cool', 'deep', 'warm', 'warmer' and 'light'
    -- style = 'light',
    -- }
    -- vim.o.background = 'light'
    -- Enable theme
    -- require('onedark').load()
  end,
}
