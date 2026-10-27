local theme = require 'custom.theme'
require('lazy').load { plugins = { 'lualine.nvim' } }
require('lazy').load { plugins = { 'lazygit.nvim' } }
require('lazy').load { plugins = { 'dressing.nvim', 'noice.nvim', 'blink.cmp', 'telescope.nvim' } }

for _, background in ipairs { 'light', 'dark', 'light' } do
  local channel = background == 'dark' and '1919' or 'ffff'
  vim.api.nvim_exec_autocmds('TermResponse', {
    data = { sequence = '\027]11;rgb:' .. channel .. '/' .. channel .. '/' .. channel .. '\027\\' },
  })
  local dark = background == 'dark'
  assert(require('nvconfig').base46.theme == (dark and 'zenburn' or 'flexoki-light'), 'terminal background did not update Base46')
  local statusline = vim.api.nvim_get_hl(0, { name = 'lualine_c_normal' })
  local mode = vim.api.nvim_get_hl(0, { name = 'lualine_a_normal' })
  assert(statusline.bg == nil, 'statusline lost terminal transparency')
  assert(statusline.fg == (dark and 0xdcdccc or 0x403e3c), 'statusline text did not follow background')
  assert(mode.fg == (dark and 0xa0c4d7 or 0x205ea6), 'statusline mode did not follow background')
  for _, state in ipairs { 'normal', 'insert', 'visual', 'replace', 'command', 'terminal', 'inactive' } do
    for _, section in ipairs { 'a', 'b', 'c', 'z' } do
      local group = 'lualine_' .. section .. '_' .. state
      assert(vim.api.nvim_get_hl(0, { name = group }).bg == nil, group .. ' has an opaque background')
    end
  end
  for _, group in ipairs { 'StatusLine', 'StatusLineNC' } do
    local hl = vim.api.nvim_get_hl(0, { name = group })
    assert(hl.bg == nil and not hl.reverse, group .. ' has an opaque background')
  end
  for _, group in ipairs { 'NormalFloat', 'BlinkCmpMenu', 'BlinkCmpDoc', 'BlinkCmpSignatureHelp', 'NoiceCmdlinePopup' } do
    local hl = vim.api.nvim_get_hl(0, { name = group, link = false })
    assert(hl.bg == (dark and 0x3f3f3f or 0xf2f0e5), group .. ' did not follow the floating window theme')
  end
  assert(
    vim.api.nvim_get_hl(0, { name = 'TelescopePromptNormal', link = false }).bg == (dark and 0x3f3f3f or 0xf2f1ed),
    'Telescope background did not follow its palette'
  )
  local border = vim.api.nvim_get_hl(0, { name = 'TelescopePromptBorder', link = false })
  assert(border.fg ~= border.bg, 'Telescope rounded border is invisible')
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
