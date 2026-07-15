local function jump_with_beacon()
  require('flash').jump {
    action = function(match, state)
      local jump = require 'flash.jump'
      jump.jump(match, state)
      jump.on_jump(state)

      require('custom.jump_beacon').pulse()
    end,
  }
end

return {
  'folke/flash.nvim',
  event = 'VeryLazy',
  opts = {
    -- 1. 全局配置：针对普通 /?*# 等搜索
    min_pattern_length = 2,
    modes = {
      char = {
        enabled = true, -- f/t 这种行内跳转可以不用增强功能，或者关掉以保持原生感
        min_pattern_length = 0,
        multi_line = true, -- 如果你希望 f 跳得更远，可以开启这个
        autohide = false, -- 自动跳转：如果当前行只有一个匹配项，按了 f{char} 直接跳过去，不显标签
        -- 只有当你在 1 秒内连续按同一个键时，才显示标签（比如按 f 之后没跳到想去的地方，再按一次 f）
        jump_labels = function(motion)
          return motion:find 'f' or motion:find 'F'
        end,
      },
      search = {
        enabled = false, -- 保持原生 /? 搜索，避免输入过程中被 label 提前截断
      },
    },
    labels = 'asdfghjklqwertyuiopzxcvbnm',
    label = {
      uppercase = false, -- 只使用小写字母
      -- 在标签两侧加上空格或括号，形成“按钮感”
      format = function(opts)
        return { { ' ' .. opts.match.label .. ' ', 'FlashLabel' } }
      end,
      style = 'overlay', -- 悬浮在字符上方，配合明显的背景色
      distance = true, -- 距离光标近的优先分配好按的键
      min_pattern_length = 2, -- 只有输入两个字符后才显示标签，减少视觉疲劳
      rainbow = { -- 开启彩虹色区分
        enabled = true,
        shade = 6,
      },
    },
  },
  keys = {
    {
      's',
      function()
        jump_with_beacon()
      end,
      mode = { 'n', 'x', 'o' },
      desc = 'Flash Jump',
    },
    {
      'S',
      function()
        require('flash').treesitter()
      end,
      mode = { 'n', 'x', 'o' },
      desc = 'Flash Treesitter',
    },
  },
}
