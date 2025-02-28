return {
  'kevinhwang91/nvim-ufo',
  dependencies = {
    'kevinhwang91/promise-async',
  },
  config = function(_, opts)
    -- 折叠列设置
    vim.o.foldcolumn = '1' -- '0' 是不显示折叠列
    vim.o.foldlevel = 99 -- 使用很大的数字，默认打开所有折叠
    vim.o.foldlevelstart = 99
    vim.o.foldenable = true
    -- vim.o.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]

    require('ufo').setup(opts)
  end,
}
