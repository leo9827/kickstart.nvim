return {
  'numToStr/FTerm.nvim',
  keys = {
    -- 1. 使用 Control + t 切换浮动终端 (n: 普通模式, t: 终端模式)
    {
      '<C-t>',
      function()
        require('FTerm').toggle()
      end,
      mode = { 'n', 't' },
      desc = 'Terminal (FTerm)',
    },

    -- 2. 使用 Leader + ft 切换浮动终端 (符合 LazyVim 习惯)
    {
      '<leader>tf',
      function()
        require('FTerm').toggle()
      end,
      mode = { 'n', 't' },
      desc = 'Floating Terminal',
    },
  },
  opts = {
    border = 'rounded',
    dimensions = {
      height = 0.9,
      width = 0.9,
    },
  },
}
