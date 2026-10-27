local M = {}
local applied_background

local themes = {
  light = {
    base46 = 'flexoki-light',
    float = { bg = '#f2f0e5', border = '#b7b5ac', selection = '#deddd2' },
    telescope = { bg = '#f2f1ed', border = '#b7b6b1', selection = '#deded9' },
    statusline = {
      fg = '#403e3c',
      muted = '#6f6e69',
      normal = '#205ea6',
      insert = '#4d6632',
      visual = '#7955a1',
      replace = '#af3029',
      command = '#8b6000',
    },
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
    float = { bg = '#3f3f3f', border = '#707068', selection = '#55554d' },
    statusline = {
      fg = '#dcdccc',
      muted = '#a0a093',
      normal = '#a0c4d7',
      insert = '#b4c89a',
      visual = '#cfb0d4',
      replace = '#e0a3a3',
      command = '#e0cf9f',
    },
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
  config.options.theme = M.lualine_theme()
  lualine.setup(config)
end

local function apply_highlights()
  for group, spec in pairs(current().highlights) do
    vim.api.nvim_set_hl(0, group, spec)
  end
  local colors = current().statusline
  local float = current().float
  vim.api.nvim_set_hl(0, 'StatusLine', { fg = colors.fg, bg = 'NONE' })
  vim.api.nvim_set_hl(0, 'StatusLineNC', { fg = colors.muted, bg = 'NONE' })
  vim.api.nvim_set_hl(0, 'NormalFloat', { fg = colors.fg, bg = float.bg })
  vim.api.nvim_set_hl(0, 'FloatBorder', { fg = float.border, bg = float.bg })
  vim.api.nvim_set_hl(0, 'FloatTitle', { fg = colors.normal, bg = float.bg, bold = true })
  vim.api.nvim_set_hl(0, 'FloatSelection', { fg = colors.fg, bg = float.selection, bold = true })
  local telescope = current().telescope or float
  vim.api.nvim_set_hl(0, 'TelescopeNormal', { fg = colors.fg, bg = telescope.bg })
  vim.api.nvim_set_hl(0, 'TelescopeBorder', { fg = telescope.border, bg = telescope.bg })
  vim.api.nvim_set_hl(0, 'TelescopeTitle', { fg = colors.normal, bg = telescope.bg, bold = true })
  vim.api.nvim_set_hl(0, 'TelescopeSelection', { fg = colors.fg, bg = telescope.selection, bold = true })

  -- Keep lazy-loaded plugin surfaces consistent when the terminal changes theme.
  local links = {
    BlinkCmpMenu = 'NormalFloat',
    BlinkCmpMenuBorder = 'FloatBorder',
    BlinkCmpMenuSelection = 'FloatSelection',
    BlinkCmpDoc = 'NormalFloat',
    BlinkCmpDocBorder = 'FloatBorder',
    BlinkCmpSignatureHelp = 'NormalFloat',
    BlinkCmpSignatureHelpBorder = 'FloatBorder',
    NoiceCmdlinePopup = 'NormalFloat',
    NoiceCmdlinePopupBorder = 'FloatBorder',
    NoiceCmdlinePopupBorderSearch = 'FloatBorder',
    NoiceCmdlinePopupTitle = 'FloatTitle',
    NoicePopupmenu = 'NormalFloat',
    NoicePopupmenuBorder = 'FloatBorder',
    NoicePopupmenuSelected = 'FloatSelection',
    TelescopePromptNormal = 'TelescopeNormal',
    TelescopePromptBorder = 'TelescopeBorder',
    TelescopeResultsBorder = 'TelescopeBorder',
    TelescopePreviewBorder = 'TelescopeBorder',
    TelescopePromptTitle = 'TelescopeTitle',
    TelescopeResultsTitle = 'TelescopeTitle',
    TelescopePreviewTitle = 'TelescopeTitle',
    TelescopePromptPrefix = 'TelescopeTitle',
  }
  for group, target in pairs(links) do
    vim.api.nvim_set_hl(0, group, { link = target })
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
  if applied_background == background then
    return
  end
  -- Set before changing the option: OptionSet can call back into this function.
  applied_background = background
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
  local colors = current().statusline
  local result = {}
  for _, mode in ipairs { 'normal', 'insert', 'visual', 'replace', 'command', 'terminal', 'inactive' } do
    result[mode] = {
      a = { fg = colors[mode] or colors.muted, bg = 'NONE', gui = 'bold' },
      b = { fg = colors.muted, bg = 'NONE' },
      -- Transparent sections inherit the terminal's material and opacity.
      c = { fg = colors.fg, bg = 'NONE' },
      z = { fg = colors.normal, bg = 'NONE' },
    }
  end
  return result
end

return M
