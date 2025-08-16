return {
  -- noice.nvim - 优雅的通知和命令行UI管理插件
  -- 主要功能：
  --   1. 优化命令行界面外观和交互
  --   2. 美化通知提示样式
  --   3. 改进 LSP 消息显示
  --
  -- 常用命令:
  --   :Noice - 查看通知历史
  --   :NoiceDisable - 临时禁用
  --   :NoiceEnable - 重新启用
  --
  -- 常用快捷键:
  --   <C-f> - 在较长消息中向前滚动
  --   <C-b> - 在较长消息中向后滚动
  --   <Enter> - 确认当前选择
  --   <Esc> - 关闭弹出窗口
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
