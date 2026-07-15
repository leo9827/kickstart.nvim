return {
  -- 一个功能丰富的面包屑导航栏插件，可以帮助你在代码中快速导航和跳转
  'Bekaboo/dropbar.nvim',
  lazy = true, -- Delay load until needed
  event = { 'BufReadPost', 'BufNewFile' }, -- Load when opening files
  config = function()
    require('dropbar').setup {
      -- 常规设置
      bar = {
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
        -- 使用默认快捷键配置
        quick_navigation = true,
      },
      -- 预览设置
      preview = {
        enable = true, -- 是否启用预览
        max_width = 80, -- 最大宽度
        max_height = 20, -- 最大高度
      },
    }

    local dropbar_api = require 'dropbar.api'
    vim.keymap.set('n', '<Leader>;', dropbar_api.pick, { desc = 'Pick symbols in winbar' })
    vim.keymap.set('n', '[;', dropbar_api.goto_context_start, { desc = 'Go to start of current context' })
    vim.keymap.set('n', '];', dropbar_api.select_next_context, { desc = 'Select next context' })
  end,
}
