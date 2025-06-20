-- oil.nvim 是一个文件浏览器插件，它可以让你在 Neovim 中像编辑文本一样浏览和操作文件系统
-- 主要功能：
-- 1. 在buffer中以文本方式浏览目录内容
-- 2. 支持文件/目录的创建、删除、重命名、移动等操作
-- 3. 支持预览文件内容
-- 4. 支持文件过滤和排序
-- 5. 支持浮动窗口模式
return {
  'stevearc/oil.nvim',
  ---@module 'oil'
  ---@type oil.SetupOpts
  opts = {
    -- 默认视图类型: 'tree'(树形) 或 'list'(列表)
    view_options = {
      show_hidden = false, -- 是否显示隐藏文件
    },
    -- 浮动窗口配置
    float = {
      padding = 2, -- 窗口内边距
      max_width = 100, -- 最大宽度
      max_height = 50, -- 最大高度
      border = 'rounded', -- 边框样式
    },
    -- 按键映射配置
    keymaps = {
      ['g?'] = 'actions.show_help', -- 显示帮助
      ['<CR>'] = 'actions.select', -- 选择文件/进入目录
      ['<C-v>'] = 'actions.select_vsplit', -- 垂直分屏打开
      ['<C-s>'] = 'actions.select_split', -- 水平分屏打开
      ['<C-t>'] = 'actions.select_tab', -- 新标签页打开
      ['<C-p>'] = 'actions.preview', -- 预览文件
      ['<C-c>'] = 'actions.close', -- 关闭oil窗口
      ['<C-r>'] = 'actions.refresh', -- 刷新目录
    },
    -- 使用图标显示文件类型
    use_default_keymaps = true, -- 是否使用默认键位映射
  },
  -- 可选依赖：文件图标支持
  dependencies = { { 'echasnovski/mini.icons', opts = {} } },
  -- 也可以使用 nvim-web-devicons 作为图标提供者
  -- dependencies = { "nvim-tree/nvim-web-devicons" },

  -- 不建议延迟加载，因为可能会导致某些情况下功能不正常
  lazy = false,
}
