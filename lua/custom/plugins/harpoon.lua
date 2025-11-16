return {
  'ThePrimeagen/harpoon',
  branch = 'harpoon2',
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()
    -- 调用 setup() 是必须的
    local harpoon = require 'harpoon'
    harpoon:setup()

    -- --- 基础快捷键 ---

    -- 打开/关闭 Harpoon 菜单
    vim.keymap.set('n', '<leader>me', function()
      harpoon.ui:toggle_quick_menu(harpoon:list())
    end, { desc = 'Harpoon: 打开快速菜单' })

    -- 添加当前文件到 Harpoon 列表
    vim.keymap.set('n', '<leader>ma', function()
      harpoon:list():append()
    end, { desc = 'Harpoon: 添加文件' })

    -- --- 快速导航 ---
    -- 使用 Ctrl + 数字键快速跳转

    -- 跳转到列表中的第 1 个文件
    vim.keymap.set('n', '<C-1>', function()
      harpoon:list():select(1)
    end, { desc = 'Harpoon: 跳转到文件 1' })

    -- 跳转到列表中的第 2 个文件
    vim.keymap.set('n', '<C-2>', function()
      harpoon:list():select(2)
    end, { desc = 'Harpoon: 跳转到文件 2' })

    -- 跳转到列表中的第 3 个文件
    vim.keymap.set('n', '<C-3>', function()
      harpoon:list():select(3)
    end, { desc = 'Harpoon: 跳转到文件 3' })

    -- 也可以设置循环跳转
    vim.keymap.set('n', '<C-n>', function()
      harpoon:list():next()
    end, { desc = 'Harpoon: 下一个' })
    vim.keymap.set('n', '<C-p>', function()
      harpoon:list():prev()
    end, { desc = 'Harpoon: 上一个' })
  end,
}
