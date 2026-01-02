-- Neo-tree 是常用的文件树插件
-- https://github.com/nvim-neo-tree/neo-tree.nvim
-- 快捷键：
-- * "\"  在当前文件位置打开/关闭文件树
-- * <CR> 使用窗口选择器打开文件，<space> 展开/折叠目录

return {
  'nvim-neo-tree/neo-tree.nvim',
  branch = 'v3.x',
  lazy = false, -- neo-tree will lazily load itself
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
          -- autoselect_one = true,
          bo = {
            filetype = { 'neo-tree', 'neo-tree-popup', 'notify' },
            buftype = { 'terminal', 'quickfix' },
          },
        },
      },
    },
  },
  keys = {
    { '\\', ':Neotree reveal<CR>', desc = 'NeoTree reveal', silent = true },
  },
  opts = {
    close_if_last_window = true, -- Neo-tree 成为最后一个窗口时自动关闭
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
          ['<cr>'] = 'open_with_window_picker',
        },
      },
    },
  },
}
