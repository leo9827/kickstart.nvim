return {
  'ray-x/go.nvim',
  dependencies = {
    'ray-x/guihua.lua',
    'neovim/nvim-lspconfig',
    'nvim-treesitter/nvim-treesitter',
  },
  config = function()
    require('go').setup {
      -- Add some useful defaults
      go = 'go', -- go command, can be go[default] or go1.18beta1
      goimport = 'gopls', -- goimport command, can be gopls[default] or goimport
      fillstruct = 'gopls', -- can be nil (use fillstruct, slower) and gopls
      gofmt = 'goimports', -- gofmt cmd, gofmt | goimports | gofumpt | golines
      -- -- max_line_len = 120, -- max line length in goline format(need gofmt='golines')
      tag_transform = false, -- tag_transfer  check gomodifytags for details
      test_template = '', -- default to testify if not set; g:go_nvim_tests_template  check gotests for details
      test_template_dir = '', -- default to nil if not set; g:go_nvim_tests_template_dir  check gotests for details
      comment_placeholder = '', -- comment_placeholder your cool placeholder e.g.
      icons = { breakpoint = '🧘', currentpos = '🏃' },
      verbose = false, -- output loginf in messages
      -- lsp configs
      lsp_gofumpt = false, -- true: set default gofmt in gopls format to gofumpt
      lsp_on_attach = false, -- if a on_attach function provided: attach on_attach function to gopls
      lsp_cfg = false, -- true: use non-default gopls setup specified in go/lsp.lua
      -- dap_debug = true, -- set to true to enable dap
    }

    -- Format on save
    -- local format_sync_grp = vim.api.nvim_create_augroup('GoFormat', {})
    -- vim.api.nvim_create_autocmd('BufWritePre', {
    --   pattern = '*.go',
    --   callback = function()
    --     require('go.format').goimports()
    --   end,
    --   group = format_sync_grp,
    -- })
  end,
  ft = { 'go', 'gomod', 'gowork', 'gotmpl' }, -- Load on Go file types
  build = ':lua require("go.install").update_all_sync()', -- Installs/updates all Go binaries used by go.nvim (e.g. gopls, goimports, etc.)
}
