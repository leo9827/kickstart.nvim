-- 平滑滚动插件，让Neovim滚动更加丝滑
-- 主要功能：
--   - 为常用的滚动命令添加平滑动画效果
--   - 可自定义滚动动画、速度和表现
--
-- 常用快捷键：
--   - <C-u>: 向上滚动半页
--   - <C-d>: 向下滚动半页
--   - <C-b>: 向上滚动一页
--   - <C-f>: 向下滚动一页
--   - <C-y>: 向上滚动一行
--   - <C-e>: 向下滚动一行
--   - zt: 将当前行移到屏幕顶部
--   - zz: 将当前行移到屏幕中间
--   - zb: 将当前行移到屏幕底部

return {
  'karb94/neoscroll.nvim',
  opts = {},
  config = function()
    require('neoscroll').setup {
      mappings = {
        '<C-u>',
        '<C-d>',
        '<C-b>',
        '<C-f>',
        '<C-y>',
        '<C-e>',
        'zt',
        'zz',
        'zb',
      },
      hide_cursor = true, -- 滚动时隐藏光标
      stop_eof = true, -- 在文件开头/结尾处停止滚动
      respect_scrolloff = true, -- 如果为 true，它会尝试滚动到 scrolloff 的位置
      cursor_scrolls_alone = true, -- 如果光标在屏幕内移动，则不滚动窗口
      -- easing_function = 'quadratic', -- 动画效果，可选 "linear", "quadratic", "cubic", "pow4", "sine", "circular", "bounce", "gauss" 等
      easing_function = 'sine', -- 动画效果，可选 "linear", "quadratic", "cubic", "pow4", "sine", "circular", "bounce", "gauss" 等
      pre_hook = nil, -- 滚动前执行的函数
      post_hook = nil, -- 滚动后执行的函数
      performance_options = {
        -- 帧率，数值越高动画越快、越平滑，但可能消耗更多 CPU
        framerate = 24,
        -- 每次滚动的持续时间（毫秒）
        duration = 20,
      },
    }
  end,
}
