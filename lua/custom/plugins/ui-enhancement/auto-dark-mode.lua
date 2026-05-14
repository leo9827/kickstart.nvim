-- ============================================
-- Theme Configuration
-- Modify these values to change light/dark theme pairs
-- ============================================
local LIGHT_THEME = 'flexoki-light'
local DARK_THEME = 'kanagawa'
local LIGHT_LUALINE = 'solarized_light'
local DARK_LUALINE = 'iceberg_dark'
-- ============================================

local function set_base46_theme(theme)
  if not theme or theme == '' then
    return
  end

  -- Update nvconfig
  local ok_nvconfig, nvconfig = pcall(require, 'nvconfig')
  if ok_nvconfig and nvconfig.base46 then
    nvconfig.base46.theme = theme
  end

  -- Update global config
  if vim.g.nvconfig and vim.g.nvconfig.base46 then
    vim.g.nvconfig.base46.theme = theme
  end
end

local function reload_base46(theme)
  local ok_base46, base46 = pcall(require, 'base46')
  if not ok_base46 then
    return
  end

  -- Ensure cache directory exists
  if not vim.g.base46_cache or vim.g.base46_cache == '' then
    vim.g.base46_cache = vim.fn.stdpath 'data' .. '/base46_cache/'
  end
  vim.fn.mkdir(vim.g.base46_cache, 'p')

  -- Set theme and reload highlights
  set_base46_theme(theme)
  pcall(base46.load_all_highlights)
end

local function refresh_lualine(lualine_theme)
  local ok_lualine, lualine = pcall(require, 'lualine')
  if not ok_lualine then
    return
  end

  local config = lualine.get_config and lualine.get_config()
  if config then
    config.options = config.options or {}
    config.options.theme = lualine_theme
    lualine.setup(config)
  elseif lualine.refresh then
    lualine.refresh()
  end
end

local function apply_light_mode()
  vim.o.background = 'light'
  reload_base46(LIGHT_THEME)
  refresh_lualine(LIGHT_LUALINE)
end

local function apply_dark_mode()
  vim.o.background = 'dark'
  reload_base46(DARK_THEME)
  refresh_lualine(DARK_LUALINE)
end

return {
  'f-person/auto-dark-mode.nvim',
  dependencies = { 'NvChad/base46' },
  lazy = true,
  event = 'VimEnter', -- Load after UI is ready
  opts = {
    update_interval = 30000, -- Check system theme every 30 seconds
    set_dark_mode = apply_dark_mode,
    set_light_mode = apply_light_mode,
  },
  config = function(_, opts)
    local ok, auto_dark_mode = pcall(require, 'auto-dark-mode')
    if not ok then
      return
    end

    auto_dark_mode.setup(opts)
  end,
}
