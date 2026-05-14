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
return {
  'folke/noice.nvim',
  event = 'VeryLazy',
  dependencies = {
    'MunifTanjim/nui.nvim',
    'rcarriga/nvim-notify',
  },
  config = function()
    -- 1. Notify 配置优化
    require('notify').setup {
      merge_duplicates = true,
      background_colour = '#000000',
      fps = 60,
      timeout = 3000,
      stages = 'fade_in_slide_out',
      render = 'minimal', -- 推荐尝试 "minimal" 或 "compact"，比默认更清爽
    }

    require('noice').setup {
      -- 2. 核心视图与几何调整
      views = {
        cmdline_popup = {
          position = {
            row = '45%', -- 绝对居中通常比 40% 更舒服，或者 40% 也可以
            col = '50%',
          },
          size = {
            width = '50%', -- 改为 50%，不再局促
            height = 'auto',
          },
          border = {
            -- double | none | rounded | shadow | single | solid
            -- style = 'solid',
            style = 'rounded',
            padding = { 0, 1 },
          },
        },
        popupmenu = {
          relative = 'editor',
          position = {
            row = 8,
            col = '50%',
          },
          size = {
            width = 60,
            height = 10,
          },
          border = {
            style = 'solid',
            padding = { 0, 1 },
          },
          win_options = {
            winhighlight = 'Normal:Normal,FloatBorder:DiagnosticInfo',
          },
        },
      },

      -- 3. 路由规则：过滤噪音 (让体验变顺畅的关键)
      routes = {
        -- Neovim 0.12 在部分终端/复用器下收不到 DSR 响应，会发出启动告警。
        -- 这条消息本身不影响编辑，但被 notify 动画接管后会让 dashboard 看起来卡几秒。
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
        -- 将 "写入文件" 等消息重定向到 mini view (底部小横条)，不弹窗
        {
          filter = {
            event = 'msg_show',
            kind = '',
            find = 'written',
          },
          opts = { skip = true }, -- 或者 view = "mini"
        },
        -- 也可以把 search_count 放到 mini view
        {
          filter = {
            event = 'msg_show',
            kind = 'search_count',
          },
          opts = { skip = true }, -- 搜索计数通常不需要弹窗
        },
      },

      cmdline = {
        view = 'cmdline_popup',
        format = {
          -- 可以在这里自定义图标，看起来更顺眼
          cmdline = { pattern = '^:', icon = '', lang = 'vim' },
          search_down = { pattern = '^/', icon = '', lang = 'regex' },
          search_up = { pattern = '^%?', icon = '', lang = 'regex' },
        },
      },

      lsp = {
        -- 保持原有的配置
        override = {
          ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
          ['vim.lsp.util.stylize_markdown'] = true,
          ['cmp.entry.get_documentation'] = true,
        },
        -- 悬浮文档的边框优化
        hover = {
          enabled = true,
          silent = true, -- set to true to not show a message if hover is not available
          view = nil, -- when nil, use defaults from documentation
          opts = {}, -- merged with defaults from documentation
        },
        signature = {
          enabled = false, -- 关闭 Noice 的签名窗口，避免弹窗抢占输入焦点
          auto_open = {
            enabled = true,
            trigger = true, -- Automatically show signature help when typing a trigger character from the LSP
            luasnip = true, -- Will open signature help when jumping to Luasnip insert nodes
            throttle = 50, -- Debounce lsp signature help request by 50ms
          },
          view = nil, -- when nil, use defaults from documentation
          opts = {}, -- merged with defaults from documentation
        },
      },

      presets = {
        -- 让搜索框也居中，保持视线不用上下跳
        bottom_search = false,
        -- bottom_search = true, -- use a classic bottom cmdline for search

        -- 更好地整合 cmdline 和 popupmenu
        command_palette = true, -- position the cmdline and popupmenu together
        long_message_to_split = true, -- long messages will be sent to a split
        inc_rename = false, -- enables an input dialog for inc-rename.nvim
        lsp_doc_border = true,
      },
    }
  end,
}
