return {
  'sindrets/diffview.nvim',
  -- cmd = { 'DiffviewOpen', 'DiffviewClose', 'DiffviewFileHistory' },
  opts = {
    -- 使用 vim.keymap.set 为 diffview 设置快捷键
    keymaps = {
      -- 关闭 diffview
      ['q'] = '<Cmd>DiffviewClose<CR>',
      -- 在 diffview 中切换文件
      ['<Tab>'] = function()
        if #require('diffview.lib').get_files() > 1 then
          require('diffview.actions').select_next_entry()
        end
      end,
      ['<S-Tab>'] = function()
        if #require('diffview.lib').get_files() > 1 then
          require('diffview.actions').select_prev_entry()
        end
      end,
    },
    hooks = {
      -- 在 diffview 打开时自动调整窗口大小
      DiffviewOpened = function()
        vim.cmd 'wincmd J'
      end,
    },
  },
}
