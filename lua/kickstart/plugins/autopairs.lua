-- 自动补全括号、引号
-- https://github.com/windwp/nvim-autopairs
-- 常用操作：
-- * 插入模式输入 () [] {} "" '' 自动补全闭合
-- * <M-e>（Alt+e）快速包裹选区或当前单词
-- * Telescope/Neo-tree 等特殊窗口中自动禁用，避免误触

return {
  'windwp/nvim-autopairs',
  event = 'InsertEnter',
  opts = {
    check_ts = true, -- 利用 treesitter 更智能地处理字符串/注释
    disable_filetype = { 'TelescopePrompt', 'spectre_panel', 'neo-tree' },
    fast_wrap = {
      map = '<M-e>',
      chars = { '{', '[', '(', '"', "'" },
      pattern = string.gsub([[ [%'%"%)%>%]%)%}%,] ]], '%s+', ''),
      offset = 0,
      end_key = '$',
      keys = 'qwertyuiopzxcvbnmasdfghjkl',
      check_comma = true,
      highlight = 'PmenuSel',
      highlight_grey = 'LineNr',
    },
  },
}
