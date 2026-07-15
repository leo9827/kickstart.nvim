-- nvim-spectre: 项目级搜索与替换 (search & replace)
--
-- 功能: 在整个项目范围内查找并替换文本，支持正则、大小写、按文件类型过滤，
--       替换前可逐条预览确认，比 :%s 命令更直观强大。
--
-- 快捷键:
-- <leader>sp        打开/切换 Spectre 面板
-- <leader>sc        搜索光标下的单词 (normal) / 搜索选中内容 (visual)
-- <leader>sF        仅在当前文件内搜索替换
--
-- 面板内常用操作:
-- <CR>              跳转到对应结果
-- dd                排除/包含某条结果
-- R                 执行全部替换
-- <leader>c         替换当前光标所在的这一条
return {
  'nvim-pack/nvim-spectre',
  dependencies = { 'nvim-lua/plenary.nvim' },
  opts = {},
  keys = {
    {
      '<leader>sp',
      function()
        require('spectre').toggle()
      end,
      desc = 'Spectre: 切换面板',
    },
    {
      '<leader>sc',
      function()
        require('spectre').open_visual { select_word = true }
      end,
      desc = 'Spectre: 搜索当前单词',
    },
    {
      '<leader>sc',
      function()
        require('spectre').open_visual()
      end,
      mode = 'v',
      desc = 'Spectre: 搜索选中内容',
    },
    {
      '<leader>sF',
      function()
        require('spectre').open_file_search { select_word = true }
      end,
      desc = 'Spectre: 当前文件内搜索',
    },
  },
}
