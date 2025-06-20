return {
  'folke/noice.nvim',
  event = 'VeryLazy',
  opts = {
    -- add any options here
  },
  dependencies = {
    'MunifTanjim/nui.nvim',
    'rcarriga/nvim-notify',
  },
  config = function()
    require('notify').setup {
      background_colour = '#000000',
      fps = 60,
      timeout = 2000, -- in milliseconds
      stages = 'fade_in_slide_out', -- 'fade_in_slide_out' or 'static'
      merge_duplicates = true,
    }
    require('noice').setup {
      -- routes = {
      --   {
      --     filter = { event = 'notify' },
      --     view = 'split',
      --   },
      -- },
      views = {
        cmdline_popup = {
          position = {
            row = '40%',
            col = '50%',
          },
          size = {
            width = '25%',
            height = 'auto',
          },
          border = {
            style = 'rounded',
          },
        },
        notify = {
          replace = true,
        },
      },
      cmdline = {
        view = 'cmdline_popup',
      },
      lsp = {
        override = {
          ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
          ['vim.lsp.util.stylize_markdown'] = true,
          ['cmp.entry.get_documentation'] = true,
        },
      },
      presets = {
        bottom_search = true,
        command_palette = false,
        long_message_to_split = true,
        inc_rename = false,
        lsp_doc_border = true,
      },
    }
  end,
}
