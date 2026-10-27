-- Notification history: :Noice. Toggle temporarily with :NoiceDisable / :NoiceEnable.
return {
  'folke/noice.nvim',
  event = 'VeryLazy',
  dependencies = {
    'MunifTanjim/nui.nvim',
    'rcarriga/nvim-notify',
  },
  config = function()
    require('notify').setup {
      merge_duplicates = true,
      background_colour = 'NotifyBackground',
      fps = 60,
      timeout = 2000,
      stages = 'fade',
      render = 'minimal',
    }

    require('noice').setup {
      views = {
        cmdline_popup = {
          position = {
            row = '45%',
            col = '50%',
          },
          size = {
            width = '50%',
            height = 'auto',
          },
          border = {
            style = 'rounded',
            padding = { 0, 1 },
          },
          win_options = { winblend = 5 },
        },
        popupmenu = {
          border = {
            style = 'rounded',
            padding = { 0, 1 },
          },
          win_options = {
            winblend = 5,
          },
        },
        cmdline_popupmenu = {
          win_options = {
            winhighlight = { Normal = 'NormalFloat', FloatBorder = 'FloatBorder' },
          },
        },
        hover = { win_options = { winblend = 5 } },
      },

      routes = {
        -- Missing terminal DSR replies are harmless here; avoid animating a startup warning.
        {
          filter = {
            event = 'msg_show',
            find = 'defaults.lua: Did not detect DSR response from terminal',
          },
          opts = { skip = true },
        },
        {
          filter = {
            event = 'notify',
            find = 'defaults.lua: Did not detect DSR response from terminal',
          },
          opts = { skip = true },
        },
        -- Suppress routine save messages; search counts are shown in the statusline.
        {
          filter = {
            event = 'msg_show',
            kind = '',
            find = 'written',
          },
          opts = { skip = true },
        },
        {
          filter = {
            event = 'msg_show',
            kind = 'search_count',
          },
          opts = { skip = true },
        },
      },

      cmdline = {
        view = 'cmdline_popup',
        format = {
          cmdline = { pattern = '^:', icon = '', lang = 'vim' },
          search_down = { pattern = '^/', icon = '', lang = 'regex' },
          search_up = { pattern = '^%?', icon = '', lang = 'regex' },
        },
      },

      lsp = {
        override = {
          ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
          ['vim.lsp.util.stylize_markdown'] = true,
        },
        hover = {
          enabled = true,
          silent = true, -- set to true to not show a message if hover is not available
          view = nil, -- when nil, use defaults from documentation
          opts = {}, -- merged with defaults from documentation
        },
        signature = {
          enabled = false, -- Avoid stealing focus while typing.
          auto_open = {
            enabled = true,
            trigger = true, -- Automatically show signature help when typing a trigger character from the LSP
            throttle = 50, -- Debounce lsp signature help request by 50ms
          },
          view = nil, -- when nil, use defaults from documentation
          opts = {}, -- merged with defaults from documentation
        },
      },

      presets = {
        bottom_search = false,

        -- Let completion follow the centered input instead of pinning it to the top.
        command_palette = false,
        long_message_to_split = true, -- long messages will be sent to a split
        inc_rename = false, -- enables an input dialog for inc-rename.nvim
        lsp_doc_border = true,
      },
    }
  end,
}
