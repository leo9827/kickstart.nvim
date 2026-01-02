-- 快速跳转插件
-- 作用：提供高效的光标快速移动功能，可以在可视范围内快速跳转到任意位置
-- 常用场景：
--   1. 需要快速跳转到屏幕上某个字符/单词时
--   2. 在代码中快速定位并跳转到特定的语法结构
--   3. 替代传统的 f/F/t/T 移动命令
-- 常用快捷键(flash default shortcuts)：
-- 常用快捷键：
--   s: 启动跳转模式，输入要跳转的字符
--   S: 基于语法树的智能跳转
--   r: 在操作符待决模式下远程跳转
--   R: 在可视和操作符待决模式下搜索语法树节点
--   <c-s>: 在命令行模式下切换 Flash 搜索
--
--   n：Normal（普通）模式
--   x：Visual（可视）模式
--   o：Operator-pending（操作符等待）模式
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
        enabled = true,
      }, -- 增强/?*#等str搜索
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
    -- stylua: ignore
    keys = {
    { "f", mode = {"n", "x", "o"}, function() require("flash").jump() end, desc = "Flash Jump" },
    { "F", mode = {"n", "x", "o"}, function() require("flash").treesitter() end, desc = "Flash Treesitter" }
    -- flash default short cuts:
    -- { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash Jump" },
    -- { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
    -- { "r", mode = { "o" }, function() require("flash").remote() end, desc = "Remote Flash" },-- 映射在 'o' 模式下，输入 yr, dr, cr 即可触发远程动作，完全不影响正常的 r 键
    -- { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
    -- { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search in cmd mode" },
    },
  -- 增强版的搜索跳转 (n 键逻辑改进)
  -- -- 配合 hlslens 和居中
  -- vim.keymap.set({ 'n', 'x', 'o' }, 'n', function()
  --   -- 这是一个进阶用法：如果是 flash 模式则继续跳，否则执行普通 nzz
  --   flash.jump { continue = true }
  -- end, { desc = 'Flash Next' }),
  --
  -- 保持高亮
  vim.api.nvim_set_hl(0, 'FlashLabel', { fg = '#ffffff', bg = '#ff007c', bold = true }),
}
