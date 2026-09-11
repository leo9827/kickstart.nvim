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
  M.apply(vim.o.background)
  local group = vim.api.nvim_create_augroup('TerminalTheme', { clear = true })
  -- Colorscheme setup can disable Neovim's default OSC 11 listener.
  vim.api.nvim_create_autocmd('TermResponse', {
    group = group,
    callback = function(ev)
      local r, g, b = ev.data.sequence:match '^\027%]11;rgba?:([%x]+)/([%x]+)/([%x]+)'
      if not r then
        return
      end
      local function component(value)
        return tonumber(value, 16) / (16 ^ #value - 1)
      end
      local luminance = 0.299 * component(r) + 0.587 * component(g) + 0.114 * component(b)
      M.apply(luminance < 0.5 and 'dark' or 'light')
    end,
  })
  vim.api.nvim_create_autocmd('OptionSet', {
    group = group,
    pattern = 'background',
    callback = function()
      M.apply(vim.o.background)
    end,
  })
end

function M.apply(background)
  local selected = assert(themes[background], 'unsupported background: ' .. tostring(background))
  local config = require 'nvconfig'

  if vim.o.background ~= background then
    vim.o.background = background
  end
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
