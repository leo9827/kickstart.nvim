return {
  'ThePrimeagen/harpoon',
  branch = 'harpoon2',
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()
    -- 调用 setup() 是必须的
    local harpoon = require 'harpoon'
    harpoon:setup()

    -- 定义快捷键映射表
    local keymaps = {
      {
        key = '<leader>ma',
        action = function()
          harpoon:list():append()
        end,
        desc = 'Harpoon: 添加文件',
      },
      {
        key = '<leader>mf',
        action = function()
          harpoon.ui:toggle_quick_menu(harpoon:list())
        end,
        desc = 'Harpoon: 打开快速菜单',
      },
      {
        key = '<C-1>',
        action = function()
          harpoon:list():select(1)
        end,
        desc = 'Harpoon: 跳转到文件 1',
      },
      {
        key = '<C-2>',
        action = function()
          harpoon:list():select(2)
        end,
        desc = 'Harpoon: 跳转到文件 2',
      },
      {
        key = '<C-3>',
        action = function()
          harpoon:list():select(3)
        end,
        desc = 'Harpoon: 跳转到文件 3',
      },
      {
        key = '<C-n>',
        action = function()
          harpoon:list():next()
        end,
        desc = 'Harpoon: 下一个',
      },
      {
        key = '<C-p>',
        action = function()
          harpoon:list():prev()
        end,
        desc = 'Harpoon: 上一个',
      },
      {
        key = '<leader>md',
        action = function()
          harpoon:list():remove()
        end,
        desc = 'Harpoon: 移除当前文件',
      },
    }

    -- 统一注册所有快捷键
    for _, keymap in ipairs(keymaps) do
      vim.keymap.set('n', keymap.key, keymap.action, { desc = keymap.desc })
    end
  end,
}
