-- 快速跳转插件
-- 作用：提供高效的光标快速移动功能，可以在可视范围内快速跳转到任意位置
-- 常用场景：
--   1. 需要快速跳转到屏幕上某个字符/单词时
--   2. 在代码中快速定位并跳转到特定的语法结构
--   3. 替代传统的 f/F/t/T 移动命令
-- 常用快捷键：
--   s: 启动跳转模式，输入要跳转的字符
--   S: 基于语法树的智能跳转
--   r: 在操作符待决模式下远程跳转
--   R: 在可视和操作符待决模式下搜索语法树节点
--   <c-s>: 在命令行模式下切换 Flash 搜索

return {
  'folke/flash.nvim',
  event = 'VeryLazy',
  opts = {},
  -- stylua: ignore
  keys = {
    { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash Jump" },
    { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
    { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
    { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
    { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
  },
}

