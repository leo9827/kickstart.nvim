return {
  'nvim-lualine/lualine.nvim',
  event = 'VeryLazy',
  opts = function()
    return {
      options = {
        theme = require('custom.theme').lualine_theme(),
        section_separators = '',
        component_separators = '',
        globalstatus = true,
        disabled_filetypes = { statusline = { 'dashboard', 'alpha' } },
      },
      extensions = { 'neo-tree', 'lazy' },
      sections = {
        lualine_a = {
          { 'mode', padding = 1 },
        },
        lualine_b = {
          { 'branch', icon = '' },
          { 'diff', icons_enabled = true },
        },
        lualine_c = {
          { 'filename', file_status = true, path = 1 },
          { 'diagnostics', sources = { 'nvim_diagnostic' } },
          {
            function()
              local register = vim.fn.reg_recording()
              if register == '' then
                return ''
              end
              return '  @' .. register
            end,
            color = 'DiagnosticWarn',
          },
        },
        lualine_x = {
          {
            function()
              return require('custom.go_tests').status()
            end,
          },
          {
            function()
              return vim.b.large_file and 'LIGHT' or ''
            end,
            color = 'DiagnosticWarn',
          },
          {
            function()
              return vim.b.autoformat_disabled and 'FMT OFF' or ''
            end,
            color = 'DiagnosticWarn',
          },
          { 'filetype', icon_only = true, separator = '', padding = { left = 1, right = 0 } },
          { 'encoding' },
          { 'fileformat' },
        },
        lualine_y = {
          {
            'searchcount',
            maxcount = 999,
            timeout = 20,
            cond = function()
              return not vim.b.large_file
            end,
          },
          { 'progress', padding = 1 },
          { 'location', padding = 1 },
        },
        lualine_z = {
          { 'datetime', style = '%H:%M', padding = 1 },
        },
      },
    }
  end,
}
