return {
  'ThePrimeagen/harpoon',
  branch = 'harpoon2',
  dependencies = { 'nvim-lua/plenary.nvim' },
  keys = {
    {
      '<leader>ma',
      function()
        require('harpoon'):list():append()
      end,
      desc = 'Harpoon: add file',
    },
    {
      '<leader>mf',
      function()
        require('harpoon').ui:toggle_quick_menu(require('harpoon'):list())
      end,
      desc = 'Harpoon: file menu',
    },
    {
      '<C-1>',
      function()
        require('harpoon'):list():select(1)
      end,
      desc = 'Harpoon: file 1',
    },
    {
      '<C-2>',
      function()
        require('harpoon'):list():select(2)
      end,
      desc = 'Harpoon: file 2',
    },
    {
      '<C-3>',
      function()
        require('harpoon'):list():select(3)
      end,
      desc = 'Harpoon: file 3',
    },
    {
      '<C-n>',
      function()
        require('harpoon'):list():next()
      end,
      desc = 'Harpoon: next file',
    },
    {
      '<C-p>',
      function()
        require('harpoon'):list():prev()
      end,
      desc = 'Harpoon: previous file',
    },
    {
      '<leader>md',
      function()
        require('harpoon'):list():remove()
      end,
      desc = 'Harpoon: remove file',
    },
  },
  config = function()
    require('harpoon'):setup()
  end,
}
