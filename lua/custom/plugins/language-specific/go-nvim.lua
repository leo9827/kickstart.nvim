return {
  'ray-x/go.nvim',
  dependencies = {
    'ray-x/guihua.lua',
    'neovim/nvim-lspconfig',
    'nvim-treesitter/nvim-treesitter',
  },
  config = function()
    require('custom.compat.lsp-codelens').patch()

    require('go').setup {
      -- Add some useful defaults
      go = 'go', -- go command, can be go[default] or go1.18beta1
      goimport = 'goimports', -- goimport command, can be gopls[default] or goimport
      fillstruct = 'gopls', -- can be nil (use fillstruct, slower) and gopls
      gofmt = 'gofumpt', -- gofmt cmd, gofmt | goimports | gofumpt | golines
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

      test_runner = 'go', -- one of {`go`,  `dlv`, `ginkgo`, `gotestsum`}
      verbose_tests = true, -- set to add verbose flag to tests deprecated, see '-v' option
      run_in_floaterm = true, -- set to true to run in a float window. :GoTermClose closes the floatterm
      -- float term recommend if you use gotestsum ginkgo with terminal color
      floaterm = { -- position
        position = 'auto', -- one of {`top`, `bottom`, `left`, `right`, `center`, `auto`}
        width = 0.45, -- width of float window if not auto
        height = 0.90, -- height of float window if not auto
        title_colors = 'nord', -- default to nord, one of {'nord', 'tokyo', 'dracula', 'rainbow', 'solarized ', 'monokai'}
        -- can also set to a list of colors to define colors to choose from
        -- e.g {'#D8DEE9', '#5E81AC', '#88C0D0', '#EBCB8B', '#A3BE8C', '#B48EAD'}
      },
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
}
