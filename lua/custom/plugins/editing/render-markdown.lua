return {
  'MeanderingProgrammer/render-markdown.nvim',
  ft = 'markdown',
  dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.icons' },
  opts = {
    ignore = function(bufnr)
      return require('custom.large_file').is_large(bufnr)
    end,
  },
}
