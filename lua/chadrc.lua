-- NvChad configuration
-- This file is loaded by NvChad/ui/lua/nvconfig.lua
local M = {}

-- Base46 theme configuration
M.base46 = {
  theme = 'flexoki-light', -- Choose your theme
  transparency = true, -- Set to true for transparent background

  hl_override = {
    -- You can override highlight groups here
    -- Example:
    -- Comment = { italic = true },
  },

  hl_add = {
    -- Add new highlight groups here
  },

  integrations = {
    -- Enable/disable integrations with other plugins
  },

  changed_themes = {
    -- Theme-specific overrides
  },
}

-- UI component settings (for NvChad/ui plugin)
M.ui = {
  tabufline = {
    enabled = false, -- Using bufferline instead
  },
  statusline = {
    enabled = false, -- Using lualine instead
  },
}

return M
