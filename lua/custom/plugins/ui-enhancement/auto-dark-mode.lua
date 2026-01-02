local function reload_base46()
  local ok_base46, base46 = pcall(require, 'base46')
  if not ok_base46 then
    return
  end

  if not vim.g.base46_cache or vim.g.base46_cache == '' then
    vim.g.base46_cache = vim.fn.stdpath 'data' .. '/base46_cache/'
  end

  vim.fn.mkdir(vim.g.base46_cache, 'p')

  local required_files = { 'defaults', 'syntax', 'treesitter' }
  local missing = false

  for _, file in ipairs(required_files) do
    if not vim.uv.fs_stat(vim.g.base46_cache .. file) then
      missing = true
      break
    end
  end

  if missing then
    pcall(base46.compile)
  end

  for _, file in ipairs(required_files) do
    pcall(dofile, vim.g.base46_cache .. file)
  end
end

return {
  'f-person/auto-dark-mode.nvim',
  lazy = false,
  opts = {
    update_interval = 30000, -- check every 30s
    set_dark_mode = function()
      vim.o.background = 'dark'
      reload_base46()
    end,
    set_light_mode = function()
      vim.o.background = 'light'
      reload_base46()
    end,
  },
  config = function(_, opts)
    local ok, auto_dark_mode = pcall(require, 'auto-dark-mode')
    if not ok then
      return
    end

    auto_dark_mode.setup(opts)
    auto_dark_mode.init()
  end,
}
