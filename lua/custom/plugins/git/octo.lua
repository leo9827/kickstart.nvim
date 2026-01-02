-- Octo: 在 Neovim 中管理 GitHub Issues 和 Pull Requests
-- 功能: 无需离开编辑器即可浏览、创建、评论 GitHub 的 PR 和 Issue
return {
  'pwntester/octo.nvim',
  cmd = 'Octo',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-telescope/telescope.nvim',
    'nvim-tree/nvim-web-devicons',
  },
  keys = {
    -- <leader>gpr: 列出当前仓库的所有 Pull Request，可查看状态和详情
    { '<leader>gpr', '<cmd>Octo pr list<cr>', desc = 'List PRs' },
    -- <leader>gpc: 创建新的 Pull Request，填写标题、描述等信息
    { '<leader>gpc', '<cmd>Octo pr create<cr>', desc = 'Create PR' },
    -- <leader>gis: 列出当前仓库的所有 Issue，可查看和筛选
    { '<leader>gis', '<cmd>Octo issue list<cr>', desc = 'List issues' },
    -- <leader>gic: 创建新的 Issue，提交 Bug 或功能请求
    { '<leader>gic', '<cmd>Octo issue create<cr>', desc = 'Create issue' },
  },
  config = function()
    require('octo').setup {
      enable_builtin = true, -- 启用内置功能
      default_to_projects_v2 = true, -- 默认使用 GitHub Projects v2
      suppress_missing_scope = {
        projects_v2 = true, -- 抑制 projects_v2 缺失权限的警告
      },
    }
  end,
}
