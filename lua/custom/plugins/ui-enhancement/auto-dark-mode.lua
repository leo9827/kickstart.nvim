local function set_base46_theme(theme)
  if not theme or theme == '' then
    return
  end

  local ok_nvconfig, nvconfig = pcall(require, 'nvconfig')
  if ok_nvconfig and nvconfig.base46 then
    nvconfig.base46.theme = theme
  end

  if vim.g.nvconfig and vim.g.nvconfig.base46 then
    vim.g.nvconfig.base46.theme = theme
  end
end

local function current_theme()
  local ok_nvconfig, nvconfig = pcall(require, 'nvconfig')
  if ok_nvconfig and nvconfig.base46 and nvconfig.base46.theme then
    return nvconfig.base46.theme
  end
  if vim.g.nvconfig and vim.g.nvconfig.base46 and vim.g.nvconfig.base46.theme then
    return vim.g.nvconfig.base46.theme
  end
end

local function detect_theme_pair()
  local theme = current_theme()
  if not theme then
    return { light = nil, dark = nil }
  end

  local light_theme = theme
  local dark_theme = theme

  if type(theme) == 'string' then
    local without_light_suffix = theme:gsub('[-_]light.*$', '')
    if without_light_suffix ~= theme then
      dark_theme = without_light_suffix ~= '' and without_light_suffix or theme
    else
      local without_dark_suffix = theme:gsub('[-_]dark.*$', '')
      if without_dark_suffix ~= theme then
        light_theme = without_dark_suffix ~= '' and without_dark_suffix or theme
      end
    end
  end

  return { light = light_theme, dark = dark_theme }
end

local function reload_base46(theme)
  local ok_base46, base46 = pcall(require, 'base46')
  if not ok_base46 then
    return
  end

  if not vim.g.base46_cache or vim.g.base46_cache == '' then
    vim.g.base46_cache = vim.fn.stdpath 'data' .. '/base46_cache/'
  end

  vim.fn.mkdir(vim.g.base46_cache, 'p')

  if theme then
    set_base46_theme(theme)
  end

  pcall(base46.load_all_highlights)
end

local function apply_mode(mode)
  local pair = detect_theme_pair()
  local theme = mode == 'dark' and (pair.dark or pair.light or current_theme()) or (pair.light or pair.dark or current_theme())

  vim.o.background = mode == 'dark' and 'dark' or 'light'
  reload_base46(theme)
end

return {
  'f-person/auto-dark-mode.nvim',
  dependencies = { 'NvChad/base46' },
  lazy = false,
  opts = {
    update_interval = 30000, -- check every 30s
  },
  config = function(_, opts)
    local ok, auto_dark_mode = pcall(require, 'auto-dark-mode')
    if not ok then
      return
    end

    local pair = detect_theme_pair()
    opts.light_theme = opts.light_theme or pair.light
    opts.dark_theme = opts.dark_theme or pair.dark
    opts.set_dark_mode = function()
      apply_mode 'dark'
    end
    opts.set_light_mode = function()
      apply_mode 'light'
    end
    auto_dark_mode.setup(opts)
    auto_dark_mode.init()
  end,
}
