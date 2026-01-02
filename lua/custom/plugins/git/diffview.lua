-- Diffview: VSCode 风格的 Git Diff 查看器
-- 功能: 提供强大的 Diff 视图和文件历史查看，支持并排对比和提交历史浏览
return {
  'sindrets/diffview.nvim',
  cmd = { 'DiffviewOpen', 'DiffviewClose', 'DiffviewToggleFiles', 'DiffviewFocusFiles', 'DiffviewFileHistory' },
  keys = {
    -- <leader>gd: 打开 Diff 视图，查看当前工作区相对于 HEAD 的所有改动
    { '<leader>gd', '<cmd>DiffviewOpen<cr>', desc = 'Diff view' },
    -- <leader>gh: 查看当前文件的提交历史，浏览每次提交的具体改动
    { '<leader>gh', '<cmd>DiffviewFileHistory %<cr>', desc = 'File history' },
    -- <leader>gH: 查看整个分支的提交历史，浏览所有文件的改动
    { '<leader>gH', '<cmd>DiffviewFileHistory<cr>', desc = 'Branch history' },
    -- <leader>gq: 关闭 Diff 视图，返回正常编辑模式
    { '<leader>gq', '<cmd>DiffviewClose<cr>', desc = 'Close diff' },
  },
  config = function()
    require('diffview').setup {
      enhanced_diff_hl = true, -- 增强 diff 高亮显示
      view = {
        default = { layout = 'diff2_horizontal' }, -- 默认使用水平分屏 diff 布局
        merge_tool = { layout = 'diff3_horizontal' }, -- 合并冲突时使用三向对比
      },
      file_panel = {
        listing_style = 'tree', -- 文件面板使用树形结构显示
        win_config = { width = 35 }, -- 文件面板宽度为 35 列
      },
      keymaps = {
        view = {
          -- 在 diff 视图中按 q 关闭
          ['q'] = '<Cmd>DiffviewClose<CR>',
          -- 按 Tab 切换到下一个改动的文件
          ['<Tab>'] = function()
            if #require('diffview.lib').get_files() > 1 then
              require('diffview.actions').select_next_entry()
            end
          end,
          -- 按 Shift+Tab 切换到上一个改动的文件
          ['<S-Tab>'] = function()
            if #require('diffview.lib').get_files() > 1 then
              require('diffview.actions').select_prev_entry()
            end
          end,
        },
      },
      hooks = {
        -- 打开 diff 缓冲区时自动调整窗口布局
        diff_buf_read = function()
          vim.cmd 'wincmd J'
        end,
      },
    }
  end,
}
