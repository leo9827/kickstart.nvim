-- Flash 跳转规则
-- 心智模型：
--   1. `f/F/t/T/;/,` 只负责字符跳转，尽量保持 Vim 原生手感
--   2. 这里开启了 `multi_line = true`，所以 `fc` 后可以用 `;` 跨行继续跳
--   3. `s` 是独立的 Flash Jump，用来做屏幕内全文 label 跳转
--   4. `S` 是 Flash Treesitter，用来按语法节点跳转
--   5. `/` 保持原生搜索；buffer 内模糊查找继续走 `<leader>/` 的 Telescope
-- 目标：
--   把高频的 `f` 留给低心智负担的字符运动，把全文跳转和语法跳转分离到 `s/S`
--
--   n：Normal（普通）模式
--   x：Visual（可视）模式
--   o：Operator-pending（操作符等待）模式
local function flash_palette()
  if vim.o.background == 'light' then
    return {
      FlashLabel = { fg = '#ffffff', bg = '#d81b60', bold = true },
      FlashCurrent = { fg = '#ffffff', bg = '#1565c0', bold = true },
      FlashMatch = { fg = '#202124', bg = '#ffd54f', bold = true },
    }
  end

  return {
    FlashLabel = { fg = '#ffffff', bg = '#ff007c', bold = true },
    FlashCurrent = { fg = '#111111', bg = '#ffd400', bold = true },
    FlashMatch = { fg = '#ffffff', bg = '#2f7eb5', bold = true },
  }
end

local function apply_flash_highlights()
  for group, spec in pairs(flash_palette()) do
    vim.api.nvim_set_hl(0, group, spec)
  end
end

local function setup_flash_highlight_autocmd()
  local group = vim.api.nvim_create_augroup('FlashAdaptiveHighlight', { clear = true })

  vim.api.nvim_create_autocmd('User', {
    group = group,
    pattern = 'NvThemeReload',
    callback = function()
      vim.schedule(apply_flash_highlights)
    end,
  })

  vim.api.nvim_create_autocmd('OptionSet', {
    group = group,
    pattern = 'background',
    callback = function()
      vim.schedule(apply_flash_highlights)
    end,
  })

  vim.api.nvim_create_autocmd({ 'ColorScheme', 'VimEnter' }, {
    group = group,
    callback = function()
      vim.schedule(apply_flash_highlights)
    end,
  })
end

local function jump_with_beacon()
  require('flash').jump {
    action = function(match, state)
      local jump = require 'flash.jump'
      jump.jump(match, state)
      jump.on_jump(state)

      vim.api.nvim_exec_autocmds('User', {
        pattern = 'JumpCursorBeaconPulse',
        modeline = false,
      })
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
  -- stylua: ignore
  keys = {
    {
      "s",
      mode = { "n", "x", "o" },
      function()
        jump_with_beacon()
      end,
      desc = "Flash Jump",
    },
    { "S", mode = {"n", "x", "o"}, function() require("flash").treesitter() end, desc = "Flash Treesitter" }
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
  config = function(_, opts)
    local ok, flash = pcall(require, 'flash')
    if not ok then
      return
    end

    flash.setup(opts)
    apply_flash_highlights()
    setup_flash_highlight_autocmd()
  end,
}
