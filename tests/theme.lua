local theme = require 'custom.theme'
require('lazy').load { plugins = { 'lualine.nvim' } }

for _, background in ipairs { 'light', 'dark', 'light' } do
  local channel = background == 'dark' and '1919' or 'ffff'
  vim.api.nvim_exec_autocmds('TermResponse', {
    data = { sequence = '\027]11;rgb:' .. channel .. '/' .. channel .. '/' .. channel .. '\027\\' },
  })
  local dark = background == 'dark'
  assert(require('nvconfig').base46.theme == (dark and 'zenburn' or 'flexoki-light'), 'terminal background did not update Base46')
  assert(require('lualine').get_config().options.theme == (dark and 'iceberg_dark' or 'solarized_light'), 'statusline did not follow background')
  assert(vim.api.nvim_get_hl(0, { name = 'NotifyBackground' }).bg == (dark and 0x3f3f3f or 0xf2f0e5), 'notification background did not follow')
end
theme.toggle()
assert(vim.o.background == 'dark', 'manual toggle failed')
assert(not require('lazy.core.config').plugins['auto-dark-mode.nvim'], 'system appearance poller still enabled')
print 'theme checks passed'
