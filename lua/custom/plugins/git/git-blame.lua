-- Git Blame: 在代码行尾显示 Git blame 信息
-- 功能: 显示每行代码的最后修改者、提交时间和提交信息，方便追溯代码历史
return {
  'f-person/git-blame.nvim',
  event = 'VeryLazy',
  config = function()
    require('gitblame').setup {
      enabled = false, -- 默认关闭，需要时手动开启（避免干扰）
      date_format = '%r', -- 使用相对时间格式（如 "2 days ago"）
      message_when_not_committed = 'Not committed yet', -- 未提交代码的提示信息
      virtual_text_column = 80, -- blame 信息显示在第 80 列之后
    }
  end,
  keys = {
    -- <leader>gb: 开关 Git Blame 显示，查看当前文件每行的提交信息
    { '<leader>gb', '<cmd>GitBlameToggle<cr>', desc = 'Toggle git blame' },
  },
}
