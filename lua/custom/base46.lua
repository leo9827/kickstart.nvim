-- NvChad base46 theme system configuration
-- This file sets up base46 (theme engine) and NvChad UI components
return {
  -- Base46 theme engine - must load first
  {
    'NvChad/base46',
    lazy = false,
    priority = 1000,
    config = function()
      -- Load and set global NvChad configuration
      -- nvconfig comes from NvChad/ui plugin and loads lua/chadrc.lua
      local ok_nvconfig, nvconfig = pcall(require, 'nvconfig')
      if ok_nvconfig then
        vim.g.nvconfig = nvconfig
      else
        -- Fallback: load chadrc directly if nvconfig is not available
        local ok_chadrc, chadrc = pcall(require, 'chadrc')
        if ok_chadrc then
          vim.g.nvconfig = chadrc
        end
      end
      vim.g.base46_cache = vim.fn.stdpath 'data' .. '/base46_cache/'

      -- Compile and load theme with error handling
      local ok_base46, base46 = pcall(require, 'base46')
      if ok_base46 then
        base46.load_all_highlights()
      else
        vim.notify('Failed to load base46 theme engine', vim.log.levels.WARN)
      end
    end,
  },
  -- NvChad UI components (optional, provides statusline, tabufline, etc.)
  -- Note: We disable statusline and tabufline in chadrc.lua, but keep this
  -- for nvconfig support which is needed by base46 and other plugins
  -- NvChad/ui plugin automatically initializes when loaded, no config needed
  {
    'NvChad/ui',
    lazy = true, -- Delay load since we don't use its UI components
    event = 'VeryLazy', -- Load after most plugins
    -- No config function needed - plugin auto-initializes
  },
}
