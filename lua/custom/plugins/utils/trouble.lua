-- Trouble.nvim 是一个强大的诊断列表管理插件
-- 主要功能：在独立窗口中显示项目/文件的诊断信息、LSP 引用、定义等
--
-- 常用功能和快捷键:
-- 1. <leader>xx - 打开/关闭诊断列表窗口，显示所有诊断信息
-- 2. <leader>xX - 打开/关闭当前缓冲区的诊断信息
-- 3. <leader>cs - 显示符号列表窗口(不聚焦)
-- 4. <leader>cl - 在右侧打开 LSP 相关信息窗口(定义、引用等)(不聚焦)
-- 5. <leader>xL - 打开/关闭位置列表
-- 6. <leader>xQ - 打开/关闭快速修复列表
--
-- 使用场景：
-- 1. 查看当前项目或文件中的所有警告和错误
-- 2. 快速定位和跳转到问题所在位置
-- 3. 查看符号引用和定义
-- 4. 管理位置列表和快速修复列表

return {
  'folke/trouble.nvim',
  opts = {}, -- for default options, refer to the configuration section for custom setup.
  cmd = 'Trouble',
  keys = {
    { '<leader>xx', '<cmd>Trouble diagnostics toggle<cr>', desc = 'Diagnostics (Trouble)' },
    { '<leader>xX', '<cmd>Trouble diagnostics toggle filter.buf=0<cr>', desc = 'Buffer Diagnostics (Trouble)' },
    { '<leader>cs', '<cmd>Trouble symbols toggle focus=false<cr>', desc = 'Symbols (Trouble)' },
    { '<leader>cl', '<cmd>Trouble lsp toggle focus=false win.position=right<cr>', desc = 'LSP Definitions / references / ... (Trouble)' },
    { '<leader>xL', '<cmd>Trouble loclist toggle<cr>', desc = 'Location List (Trouble)' },
    { '<leader>xQ', '<cmd>Trouble qflist toggle<cr>', desc = 'Quickfix List (Trouble)' },
  },
}
