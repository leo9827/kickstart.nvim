-- alpha.nvim 是一个启动页面插件
-- 作用：美化 neovim 的启动界面，提供多种内置主题（如 dashboard、startify、theta 等）
-- 常用场景：
--   - 启动 neovim 时显示美观的欢迎界面
--   - 快速访问最近打开的文件
--   - 显示常用按键绑定提示
--   - 创建新文件或打开项目
-- 常用方式：
--   - 默认在启动时自动显示
--   - 可以通过 :Alpha 命令手动打开启动页面
-- 快捷键（在启动页面中）：
--   - <leader>sl - 打开最后一个会话
--   - <CR> - 选择并执行当前选项
--   - q - 关闭启动页面

return {
  'goolord/alpha-nvim',
  dependencies = {
    'echasnovski/mini.icons',
    'nvim-lua/plenary.nvim',
  },
  config = function()
    require('alpha').setup(require('alpha.themes.theta').config)
    -- require'alpha'.setup(require'alpha.themes.dashboard'.config)
    -- require'alpha'.setup(require'alpha.themes.startify'.config)
    vim.api.nvim_create_user_command('Dashboard', 'Alpha', { desc = '打开 Alpha 启动页面(Dashborad).' })
  end,
}
