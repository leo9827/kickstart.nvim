local theme = require 'custom.theme'
require('lazy').load { plugins = { 'lualine.nvim' } }
require('lazy').load { plugins = { 'lazygit.nvim' } }

for _, background in ipairs { 'light', 'dark', 'light' } do
  local channel = background == 'dark' and '1919' or 'ffff'
  vim.api.nvim_exec_autocmds('TermResponse', {
    data = { sequence = '\027]11;rgb:' .. channel .. '/' .. channel .. '/' .. channel .. '\027\\' },
  })
  local dark = background == 'dark'
  assert(require('nvconfig').base46.theme == (dark and 'zenburn' or 'flexoki-light'), 'terminal background did not update Base46')
  assert(require('lualine').get_config().options.theme == (dark and 'iceberg_dark' or 'solarized_light'), 'statusline did not follow background')
  assert(vim.api.nvim_get_hl(0, { name = 'NotifyBackground' }).bg == (dark and 0x3f3f3f or 0xf2f0e5), 'notification background did not follow')
  local variant = dark and '/config.delta.yml' or '/config-light.delta.yml'
  assert(
    vim.g.lazygit_use_custom_config_file_path == 1 and vim.g.lazygit_config_file_path:sub(-#variant) == variant,
    'lazygit diff config did not follow background'
  )
  assert(vim.env.DFT_BACKGROUND == background, 'difftastic did not follow background')

  -- A repeated terminal reply must not reset highlights customized after loading.
  vim.api.nvim_set_hl(0, 'FlashLabel', { bg = 0x123456 })
  vim.api.nvim_exec_autocmds('TermResponse', {
    data = { sequence = '\027]11;rgb:' .. channel .. '/' .. channel .. '/' .. channel .. '\027\\' },
  })
  assert(vim.api.nvim_get_hl(0, { name = 'FlashLabel' }).bg == 0x123456, 'unchanged terminal theme reloaded highlights')
end
theme.toggle()
assert(vim.o.background == 'dark', 'manual toggle failed')
assert(vim.env.DFT_BACKGROUND == 'dark', 'lazygit did not follow manual toggle')
assert(not require('lazy.core.config').plugins['auto-dark-mode.nvim'], 'system appearance poller still enabled')
print 'theme checks passed'
