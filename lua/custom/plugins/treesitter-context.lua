-- 显示顶层语法上下文，帮助在滚动时保持方位感
return {
  'nvim-treesitter/nvim-treesitter-context',
  dependencies = { 'nvim-treesitter/nvim-treesitter' },
  event = { 'BufReadPost', 'BufNewFile' },
  opts = {
    max_lines = 3,
    multiline_threshold = 1,
    trim_scope = 'outer',
    mode = 'cursor',
  },
}
