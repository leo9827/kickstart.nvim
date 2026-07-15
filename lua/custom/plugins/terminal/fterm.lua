return {
  'numToStr/FTerm.nvim',
  keys = {
    {
      '<leader>tf',
      function()
        require('FTerm').toggle()
      end,
      mode = { 'n', 't' },
      desc = 'Floating Terminal',
    },
  },
  opts = {
    border = 'rounded',
    dimensions = {
      height = 0.9,
      width = 0.9,
    },
  },
}
