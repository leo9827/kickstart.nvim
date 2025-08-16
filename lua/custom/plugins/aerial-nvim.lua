-- aerial.nvim - 大纲/符号浏览器插件
--
-- 功能描述:
-- - 提供代码导航和符号大纲预览
-- - 快速查看和跳转到文件中的函数、类、变量等符号
-- - 支持多种编程语言，基于treesitter或LSP
--
-- 常用场景:
-- - 浏览较长文件时快速定位和导航代码结构
-- - 查看当前文件的函数/类等符号列表
-- - 在复杂代码中快速跳转到需要的位置
--
-- 使用方式:
-- 1. 打开/关闭大纲窗口: <leader>o
-- 2. 搜索大纲内容: <leader>so
-- 3. 在大纲中上下移动选择符号，回车跳转到对应位置
-- 4. 支持模糊搜索和过滤符号
--
-- 快捷键:
-- <leader>o - 打开/关闭大纲窗口
-- <leader>so - 打开大纲搜索(telescope)

return {
  'stevearc/aerial.nvim',
  opts = {},
  -- 可选依赖
  dependencies = {
    'nvim-treesitter/nvim-treesitter',
    'nvim-tree/nvim-web-devicons',
  },
  config = function()
    require('aerial').setup {
      -- 大纲窗口位置
      placement = 'right',
      layout = {
        -- These control the width of the aerial window.
        -- They can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
        -- min_width and max_width can be a list of mixed types.
        -- max_width = {40, 0.2} means "the lesser of 40 columns or 20% of total"
        max_width = { 120, 0.2 }, -- 窗口最大宽度
        width = nil, -- 窗口宽度
        min_width = 64,

        -- key-value pairs of window-local options for aerial window (e.g. winhl)
        win_opts = {},

        -- Determines the default direction to open the aerial window. The 'prefer'
        -- options will open the window in the other direction *if* there is a
        -- different buffer in the way of the preferred direction
        -- Enum: prefer_right, prefer_left, right, left, float
        default_direction = 'prefer_right',

        -- Determines where the aerial window will be opened
        --   edge   - open aerial at the far right/left of the editor
        --   window - open aerial to the right/left of the current window
        placement = 'window',

        -- When the symbols change, resize the aerial window (within min/max constraints) to fit
        resize_to_content = true,

        -- Preserve window size equality with (:help CTRL-W_=)
        preserve_equality = false,
      },
      nerd_font = 'auto',
      -- 是否显示导航箭头
      show_guides = true,
      -- Customize the characters used when show_guides = true
      guides = {
        -- When the child item has a sibling below it
        mid_item = '├─',
        -- When the child item is the last in the list
        last_item = '└─',
        -- When there are nested child guides to the right
        nested_top = '│ ',
        -- Raw indentation
        whitespace = '  ',
      },

      -- 是否显示图标
      show_icons = true,
      -- 是否自动打开大纲
      auto_open = false,
      -- 是否显示行号
      show_numbers = true,
      -- 是否显示当前光标所在位置的标记
      highlight_on_hover = true,
      -- 是否显示折叠标记
      show_fold_markers = true,
      -- 是否显示当前文件的完整路径
      show_full_path = false,
      -- 是否在关闭大纲时保持窗口
      keep_last = true,
    }
    -- 快捷键设置
    vim.keymap.set('n', '<leader>o', '<cmd>AerialToggle<CR>', { desc = 'Toggle outline viewer (powered by Aerial)' })
    vim.keymap.set('n', '<leader>so', '<cmd>Telescope aerial<CR>', { desc = 'Search outline (powered by Aerial)' })
  end,
}
