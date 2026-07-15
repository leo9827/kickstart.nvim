-- Neo-tree 是常用的文件树插件
-- https://github.com/nvim-neo-tree/neo-tree.nvim
-- 快捷键：
-- * "\"  在当前文件位置打开/关闭文件树
-- * <CR> 使用窗口选择器打开文件，<space> 展开/折叠目录

return {
  'nvim-neo-tree/neo-tree.nvim',
  branch = 'v3.x',
  cmd = 'Neotree',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
    'MunifTanjim/nui.nvim',
    {
      's1n7ax/nvim-window-picker',
      version = '2.*',
      opts = {
        filter_rules = {
          include_current_win = false,
          autoselect_one = true, -- 只有一个可选窗口时自动选择
          bo = {
            filetype = { 'neo-tree', 'neo-tree-popup', 'notify' },
            buftype = { 'terminal', 'quickfix' },
          },
        },
        picking_signal = function(bufnr, win_config, picking_window_info)
          -- 在窗口中间显示大字母
          return vim.api.nvim_buf_call(bufnr, function()
            vim.fn.clearmatches()
            vim.fn.matchaddpos('WindowPicker', { { 1, 1, 999 } }, 100)
            vim.api.nvim_win_set_config(win_config.win_id, {
              border = 'rounded',
              zindex = 100,
            })
          end)
        end,
        show_prompt = true,
        prompt = 'Pick window: ',
      },
    },
  },
  keys = {
    { '\\', ':Neotree reveal<CR>', desc = 'NeoTree reveal', silent = true },
  },
  opts = {
    close_if_last_window = false, -- 避免 :q 时因未保存 buffer 被 Neo-tree 强行拆窗重开
    popup_border_style = 'rounded',
    sources = { 'filesystem', 'buffers', 'git_status' },
    default_component_configs = {
      indent = { padding = 1 },
      icon = {
        folder_closed = '',
        folder_open = '',
        folder_empty = '',
      },
      git_status = {
        symbols = {
          added = '',
          modified = '',
          deleted = '',
          renamed = '',
          untracked = '★',
          ignored = '◌',
          unstaged = '✗',
          staged = '✓',
          conflict = '',
        },
      },
    },
    filesystem = {
      bind_to_cwd = true,
      follow_current_file = { enabled = true, leave_dirs_open = true }, -- 随光标同步文件树定位
      use_libuv_file_watcher = true,
      filtered_items = {
        hide_dotfiles = false,
        hide_gitignored = true,
        hide_by_name = { '.DS_Store', 'thumbs.db' },
      },
      window = {
        mappings = {
          ['\\'] = 'close_window',
          ['<space>'] = 'toggle_node',
          ['<cr>'] = 'open', -- 直接在当前窗口打开
          ['<s-cr>'] = 'open_with_window_picker', -- Shift+回车 用选择器
          ['s'] = 'open_split', -- 水平分屏
          ['v'] = 'open_vsplit', -- 垂直分屏
        },
      },
    },
  },
}
