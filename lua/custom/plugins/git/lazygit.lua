-- LazyGit: 在 Neovim 中集成完整的 Git UI
-- 功能: 提供类似独立应用的 Git 界面，支持暂存、提交、推送、分支管理等所有 Git 操作
-- 小贴士: 在 LazyGit 的输入框（如提交信息）里 ESC 无效，想取消/退出请按 <C-c>（Control + C）
return {
  'kdheepak/lazygit.nvim',
  lazy = true,
  cmd = {
    'LazyGit',
    'LazyGitConfig',
    'LazyGitCurrentFile',
    'LazyGitFilter',
    'LazyGitFilterCurrentFile',
  },
  dependencies = { 'nvim-lua/plenary.nvim' },
  keys = {
    -- <leader>gg: 打开 LazyGit 主界面，管理整个仓库的 Git 操作
    { '<leader>gg', '<cmd>LazyGit<cr>', desc = 'LazyGit' },
    -- <leader>gf: 打开当前文件的 Git 历史记录，查看文件的提交历史
    { '<leader>gF', '<cmd>LazyGitCurrentFile<cr>', desc = 'LazyGit file history' },
  },
  config = function()
    -- 浮动窗口占屏幕 90% 大小
    vim.g.lazygit_floating_window_scaling_factor = 0.9
    -- 设置浮动窗口边框字符，使用圆角边框
    vim.g.lazygit_floating_window_border_chars = { '╭', '─', '╮', '│', '╯', '─', '╰', '│' }
  end,
}
