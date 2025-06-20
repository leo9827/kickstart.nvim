return {
  'Bekaboo/dropbar.nvim',
  -- 依赖项：用于支持模糊查找功能
  dependencies = {
    'nvim-telescope/telescope-fzf-native.nvim',
    build = 'make',
  },
  config = function()
    -- 配置 dropbar
    require('dropbar').setup({
      -- 常规设置
      general = {
        enable = true, -- 是否启用插件
        attach_events = { 'BufReadPost', 'BufNewFile' }, -- 在哪些事件时启用
      },
      -- 图标设置
      icons = {
        enable = true, -- 是否显示图标
        ui = {
          bar = {
            separator = ' 󰅂 ', -- 分隔符
            extends = '…', -- 展开符号
          },
          menu = {
            separator = ' ', -- 菜单分隔符
            indicator = ' 󰅂 ', -- 指示器
          },
        },
      },
      -- 菜单设置
      menu = {
        keymaps = {
          ['<CR>'] = '<cmd>lua require("dropbar.api").select()<CR>', -- 回车选择
          ['<Esc>'] = '<cmd>lua require("dropbar.api").close()<CR>', -- ESC 关闭
          ['<C-k>'] = '<cmd>lua require("dropbar.api").hover()<CR>', -- 悬停预览
          ['q'] = '<cmd>lua require("dropbar.api").close()<CR>', -- q 关闭
        },
      },
      -- 预览设置
      preview = {
        enable = true, -- 是否启用预览
        max_width = 80, -- 最大宽度
        max_height = 20, -- 最大高度
      },
    })

    -- 获取 API
    local dropbar_api = require 'dropbar.api'

    -- 快捷键设置
    vim.keymap.set('n', '<Leader>;', dropbar_api.pick, { desc = 'Pick symbols in winbar' }) -- 在导航栏中选择符号
    vim.keymap.set('n', '[;', dropbar_api.goto_context_start, { desc = 'Go to start of current context' }) -- 跳转到当前上下文开始
    vim.keymap.set('n', '];', dropbar_api.select_next_context, { desc = 'Select next context' }) -- 选择下一个上下文
  end,
}
