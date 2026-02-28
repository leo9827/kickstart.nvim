-- hardtime.nvim
--
-- 功能: 训练Vim正确使用方式，通过限制一些操作来培养更好的编辑习惯
--
-- 限制的操作:
-- 1. 重复按 h,j,k,l (使用数字前缀如 5j 代替)
-- 2. 重复按 <Left>, <Right>, <Up>, <Down> (使用更高效的移动命令)
-- 3. 重复按 <BS>, <Space> (使用更精确的删除和插入)
--
-- 推荐替代方式:
-- - 使用 w,b,e 进行单词级移动
-- - 使用 f,t,F,T 进行行内快速跳转
-- - 使用 gg,G 等进行文档级跳转
-- - 使用 /,? 进行搜索跳转
-- - 使用 数字+移动 如 5j 代替重复按键
--
-- 快捷键:
-- :HardTimeToggle - 开启/关闭 hardtime
-- :HardTimeStats - 显示使用统计信息
--
return {
  -- 改掉坏习惯，掌握Vim操作
  'm4xshen/hardtime.nvim',
  lazy = false,
  dependencies = { 'MunifTanjim/nui.nvim', 'nvim-lua/plenary.nvim' },
  opts = {
    max_time = 1000, -- 重置计数的毫秒数
    max_count = 4, -- 在 max_time 内连续按同一个键的最大次数（建议设为 3 或 4）
    disable_mouse = false, -- 是否禁用鼠标
    hint = true, -- 开启提示

    -- 【关键配置】在这里添加不需要限制的文件类型
    disabled_filetypes = {
      'qf', -- Quickfix 列表
      'netrw', -- 原生文件浏览
      'NvimTree', -- 文件树
      'lazy', -- 插件管理器
      'mason', -- 包管理器
      'oil', -- Oil 文件编辑
      'TelescopePrompt', -- 模糊查找
      'toggleterm', -- 终端
    },

    -- 可以在这里自定义哪些键被限制
    restricted_keys = {
      ['h'] = { 'n', 'x' },
      ['j'] = { 'n', 'x' },
      ['k'] = { 'n', 'x' },
      ['l'] = { 'n', 'x' },
      -- 很多用户觉得限制 "-" 和 "+" 很烦，可以在这里去除
    },
  },
}
