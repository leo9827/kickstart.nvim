local M = {}

local themes = {
  light = {
    base46 = 'flexoki-light',
    lualine = 'solarized_light',
    highlights = {
      FlashLabel = { fg = '#ffffff', bg = '#d81b60', bold = true },
      FlashCurrent = { fg = '#ffffff', bg = '#1565c0', bold = true },
      FlashMatch = { fg = '#202124', bg = '#ffd54f', bold = true },
      JumpCursorBeaconStrong = { bg = '#ffcc00' },
      JumpCursorBeaconSoft = { bg = '#b26a00' },
      NotifyBackground = { bg = '#f2f0e5' },
    },
  },
  dark = {
    base46 = 'zenburn',
    lualine = 'iceberg_dark',
    highlights = {
      FlashLabel = { fg = '#ffffff', bg = '#ff007c', bold = true },
      FlashCurrent = { fg = '#111111', bg = '#ffd400', bold = true },
      FlashMatch = { fg = '#ffffff', bg = '#2f7eb5', bold = true },
      JumpCursorBeaconStrong = { bg = '#ffcc00' },
      JumpCursorBeaconSoft = { bg = '#b26a00' },
      NotifyBackground = { bg = '#3f3f3f' },
    },
  },
}

local function current()
  return themes[vim.o.background] or themes.light
end

local function refresh_lualine()
  if not package.loaded.lualine then
    return
  end

  local lualine = require 'lualine'
  local config = lualine.get_config()
  config.options.theme = current().lualine
  lualine.setup(config)
end

local function apply_highlights()
  for group, spec in pairs(current().highlights) do
    vim.api.nvim_set_hl(0, group, spec)
  end
end

function M.setup()
  vim.g.nvconfig = require 'nvconfig'
  vim.g.base46_cache = vim.fn.stdpath 'data' .. '/base46_cache/'
  require('base46').load_all_highlights()
  apply_highlights()
end

function M.apply(background)
  local selected = assert(themes[background], 'unsupported background: ' .. tostring(background))
  local config = require 'nvconfig'

  vim.o.background = background
  config.base46.theme = selected.base46
  vim.g.nvconfig = config
  vim.fn.mkdir(vim.g.base46_cache, 'p')
  require('base46').load_all_highlights()
  apply_highlights()
  refresh_lualine()
end

function M.toggle()
  M.apply(vim.o.background == 'dark' and 'light' or 'dark')
end

function M.lualine_theme()
  return current().lualine
end

return M
