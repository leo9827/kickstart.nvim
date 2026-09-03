-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true

-- Reduce overhead from very long lines when using regex-based syntax
vim.o.synmaxcol = 300

-- Disable the built-in matchparen plugin (Treesitter/LSP are usually enough)
vim.g.loaded_matchparen = 1

-- Disable unused remote providers to avoid slow provider detection and checkhealth noise.
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0

-- Keep Go-related filetypes explicit for LSP health checks and .gotmpl files.
vim.filetype.add {
  extension = {
    gotmpl = 'gotmpl',
  },
  filename = {
    ['go.work'] = 'gowork',
  },
}

-- Resolve external development tools through Mise.
vim.env.PATH = vim.env.HOME .. '/.local/share/mise/shims:' .. vim.env.PATH

-- [[ Setting options ]]
-- See `:help vim.o`
-- NOTE: You can change these options as you wish!
--  For more options, you can see `:help option-list`

-- Make line numbers default
vim.o.number = true
vim.o.relativenumber = true
-- You can also add relative line numbers, to help with jumping.
--  Experiment for yourself to see if you like it!
-- vim.o.relativenumber = true

-- Enable mouse mode, can be useful for resizing splits for example!
vim.o.mouse = 'a'

-- Don't show the mode, since it's already in the status line
vim.o.showmode = false

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.schedule(function()
  vim.o.clipboard = 'unnamedplus'
end)

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Reload files changed outside Nvim when the current buffer is unchanged.
vim.o.autoread = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.o.signcolumn = 'yes'

-- Decrease update time
vim.o.updatetime = 500

-- Decrease mapped sequence wait time
vim.o.timeoutlen = 300
vim.o.ttimeoutlen = 10
-- timeoutlen 用于映射命令的等待，而 ttimeoutlen 专门用于终端发送的键码序列。我们只想缩短后者的等待时间。

-- Configure how new splits should be opened
vim.o.splitright = true
vim.o.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
--
--  Notice listchars is set using `vim.opt` instead of `vim.o`.
--  It is very similar to `vim.o` but offers an interface for conveniently interacting with tables.
--   See `:help lua-options`
--   and `:help lua-options-guide`
vim.o.list = true
-- vim.opt.listchars = { tab = '→ ', space = '·', trail = '•', nbsp = '␣' }
vim.opt.listchars = { tab = '→ ', space = ' ', trail = '•', nbsp = '␣' }

-- Preview substitutions live, as you type!
vim.o.inccommand = 'split'

-- Show which line your cursor is on
vim.o.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.o.scrolloff = 8

-- Ctrl-D 和 Ctrl-U 每次滚动 5 行
-- vim.o.scroll = 5

-- if performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
-- instead raise a dialog asking if you wish to save the current file(s)
-- See `:help 'confirm'`
vim.o.confirm = true

-- set tabstop and shiftwidth to 2 spaces
vim.o.tabstop = 4
vim.o.softtabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true
vim.o.smartindent = true

-- Keep persistent undo; swap files protect unsaved edits after a crash.
vim.o.backup = false

-- Better colors
vim.o.termguicolors = true

-- Show color column at 120 characters
-- vim.o.colorcolumn = '120'

-- Use one global statusline across splits.
vim.o.laststatus = 3

-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic location list' })
vim.keymap.set('n', '<leader>td', function()
  local enabled = vim.diagnostic.is_enabled { bufnr = 0 }
  vim.diagnostic.enable(not enabled, { bufnr = 0 })
end, { desc = 'Toggle buffer diagnostics' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- TIP: Disable arrow keys in normal mode
-- vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
-- vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
-- vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
-- vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- NOTE: Some terminals have colliding keymaps or are not able to send distinct keycodes
-- vim.keymap.set("n", "<C-S-h>", "<C-w>H", { desc = "Move window to the left" })
-- vim.keymap.set("n", "<C-S-l>", "<C-w>L", { desc = "Move window to the right" })
-- vim.keymap.set("n", "<C-S-j>", "<C-w>J", { desc = "Move window to the lower" })
-- vim.keymap.set("n", "<C-S-k>", "<C-w>K", { desc = "Move window to the upper" })

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.hl.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', {
    clear = true,
  }),
  callback = function()
    vim.hl.on_yank()
  end,
})

vim.api.nvim_create_autocmd('BufReadPost', {
  desc = 'Restore the last cursor position',
  group = vim.api.nvim_create_augroup('last-position-jump', { clear = true }),
  callback = function(event)
    if vim.bo[event.buf].filetype == 'gitcommit' then
      return
    end

    local mark = vim.api.nvim_buf_get_mark(event.buf, '"')
    if mark[1] < 1 or mark[1] > vim.api.nvim_buf_line_count(event.buf) then
      return
    end

    local winid = vim.fn.bufwinid(event.buf)
    if winid ~= -1 then
      pcall(vim.api.nvim_win_set_cursor, winid, mark)
    end
  end,
})

vim.api.nvim_create_autocmd({ 'FocusGained', 'BufEnter', 'CursorHold', 'CursorHoldI' }, {
  desc = 'Check for files changed outside Nvim',
  group = vim.api.nvim_create_augroup('external-file-change-check', { clear = true }),
  callback = function()
    if vim.fn.mode() == 'c' then
      return
    end

    vim.schedule(function()
      if vim.fn.mode() == 'c' then
        return
      end

      vim.cmd 'checktime'
    end)
  end,
})

-- [[ Install `lazy.nvim` plugin manager ]]
--    See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
local uv = vim.uv or vim.loop
local lazy_module = lazypath .. '/lua/lazy/init.lua'
if not uv.fs_stat(lazy_module) then
  if uv.fs_stat(lazypath) then
    local broken_path = lazypath .. '.broken'
    vim.fn.delete(broken_path, 'rf')
    vim.fn.rename(lazypath, broken_path)
  end

  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out .. '\nA broken lazy.nvim checkout was moved to: ' .. lazypath .. '.broken')
  end
end

---@type vim.Option
local rtp = vim.opt.rtp
rtp:prepend(lazypath)

require('lazy').setup({
  { 'NMAC427/guess-indent.nvim', event = 'BufReadPre' },
  {
    'folke/which-key.nvim',
    event = 'VimEnter', -- Sets the loading event to 'VimEnter'
    opts = {
      -- delay between pressing a key and opening which-key (milliseconds)
      -- this setting is independent of vim.o.timeoutlen
      delay = 0,
      icons = {
        -- set icon mappings to true if you have a Nerd Font
        mappings = vim.g.have_nerd_font,
        -- If you are using a Nerd Font: set icons.keys to an empty table which will use the
        -- default which-key.nvim defined Nerd Font icons, otherwise define a string table
        keys = vim.g.have_nerd_font and {} or {
          Up = '<Up> ',
          Down = '<Down> ',
          Left = '<Left> ',
          Right = '<Right> ',
          C = '<C-…> ',
          M = '<M-…> ',
          D = '<D-…> ',
          S = '<S-…> ',
          CR = '<CR> ',
          Esc = '<Esc> ',
          ScrollWheelDown = '<ScrollWheelDown> ',
          ScrollWheelUp = '<ScrollWheelUp> ',
          NL = '<NL> ',
          BS = '<BS> ',
          Space = '<Space> ',
          Tab = '<Tab> ',
          F1 = '<F1>',
          F2 = '<F2>',
          F3 = '<F3>',
          F4 = '<F4>',
          F5 = '<F5>',
          F6 = '<F6>',
          F7 = '<F7>',
          F8 = '<F8>',
          F9 = '<F9>',
          F10 = '<F10>',
          F11 = '<F11>',
          F12 = '<F12>',
        },
      },

      -- Document existing key chains
      spec = {
        { '<leader>s', group = '[S]earch' },
        { '<leader>t', group = '[T]oggle' },
        { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
        { '<leader>g', group = '[G]it' },
        { '<leader>w', group = '[W]orkspace' },
        { '<leader>m', group = '[M]arks' },
      },
    },
  },
  {
    'nvim-telescope/telescope.nvim',
    cmd = 'Telescope',
    keys = {
      {
        '<leader>sh',
        function()
          require('telescope.builtin').help_tags()
        end,
        desc = '[S]earch [H]elp',
      },
      {
        '<leader>sk',
        function()
          require('telescope.builtin').keymaps()
        end,
        desc = '[S]earch [K]eymaps',
      },
      {
        '<leader>sf',
        function()
          require('telescope.builtin').find_files()
        end,
        desc = '[S]earch [F]iles',
      },
      {
        '<leader>ss',
        function()
          require('telescope.builtin').builtin()
        end,
        desc = '[S]earch [S]elect Telescope',
      },
      {
        '<leader>sw',
        function()
          require('telescope.builtin').grep_string()
        end,
        desc = '[S]earch current [W]ord',
      },
      {
        '<leader>sg',
        function()
          require('telescope.builtin').live_grep()
        end,
        desc = '[S]earch by [G]rep',
      },
      {
        '<leader>sd',
        function()
          require('telescope.builtin').diagnostics()
        end,
        desc = '[S]earch [D]iagnostics',
      },
      {
        '<leader>sr',
        function()
          require('telescope.builtin').resume()
        end,
        desc = '[S]earch [R]esume',
      },
      {
        '<leader>s.',
        function()
          require('telescope.builtin').oldfiles { cwd_only = true }
        end,
        desc = '[S]earch recent files in current directory',
      },
      {
        '<leader><leader>',
        function()
          require('telescope.builtin').buffers()
        end,
        desc = 'Find existing buffers',
      },
      {
        '<leader>/',
        function()
          require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
            winblend = 10,
            lnum_highlight_group = 'LineNr',
            previewer = false,
          })
        end,
        desc = 'Fuzzily search in current buffer',
      },
      {
        '<leader>s/',
        function()
          require('telescope.builtin').live_grep {
            grep_open_files = true,
            prompt_title = 'Live Grep in Open Files',
          }
        end,
        desc = '[S]earch in open files',
      },
      {
        '<leader>sn',
        function()
          require('telescope.builtin').find_files { cwd = vim.fn.stdpath 'config' }
        end,
        desc = '[S]earch [N]eovim files',
      },
    },
    dependencies = {
      'nvim-lua/plenary.nvim',
      { -- If encountering errors, see telescope-fzf-native README for installation instructions
        'nvim-telescope/telescope-fzf-native.nvim',

        -- `build` is used to run some command when the plugin is installed/updated.
        -- This is only run then, not every time Neovim starts up.
        build = 'make',

        -- `cond` is a condition used to determine whether this plugin should be
        -- installed and loaded.
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
      { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
    },
    config = function()
      -- Telescope is a fuzzy finder that comes with a lot of different things that
      -- it can fuzzy find! It's more than just a "file finder", it can search
      -- many different aspects of Neovim, your workspace, LSP, and more!
      --
      -- The easiest way to use Telescope, is to start by doing something like:
      --  :Telescope help_tags
      --
      -- After running this command, a window will open up and you're able to
      -- type in the prompt window. You'll see a list of `help_tags` options and
      -- a corresponding preview of the help.
      --
      -- Two important keymaps to use while in Telescope are:
      --  - Insert mode: <c-/>
      --  - Normal mode: ?
      --
      -- This opens a window that shows you all of the keymaps for the current
      -- Telescope picker. This is really useful to discover what Telescope can
      -- do as well as how to actually do it!

      -- [[ Configure Telescope ]]
      -- See `:help telescope` and `:help telescope.setup()`
      require('telescope').setup {
        -- You can put your default mappings / updates / etc. in here
        --  All the info you're looking for is in `:help telescope.setup()`
        --
        -- defaults = {
        --   mappings = {
        --     i = { ['<c-enter>'] = 'to_fuzzy_refine' },
        --   },
        -- },
        -- 使用 flex 策略实现响应式布局,并调整了排序方式
        defaults = {
          -- 1. 改变排序策略：让结果从上往下排列，输入框固定在顶部
          -- 这样你的视线不需要在屏幕上下反复横跳
          sorting_strategy = 'ascending', -- descending or ascending
          layout_strategy = 'flex', -- 使用 flex 策略，自动切换横/纵向布局

          layout_config = {
            -- 2. 调整 prompt (输入框) 的位置 top / bottom
            prompt_position = 'top',

            -- 3. 整体窗口大小设置 (百分比)
            width = 0.90, -- 占用屏幕宽度的 90%
            height = 0.85, -- 占用屏幕高度的 85%

            -- 4. 横向布局配置 (宽屏时)
            horizontal = {
              preview_width = 0.55, -- 预览窗口占 55%，列表占 45% (内容优先)
            },

            -- 5. 纵向布局配置 (窄屏时)
            vertical = {
              mirror = false, -- 如果为 true，预览窗口会在列表上方
              preview_height = 0.5, -- 预览窗口占高度的 50%
            },
          },

          -- 6. 路径显示优化
          -- 智能截断路径，防止文件名太长导致看不见
          path_display = { 'truncate' },

          -- 移除选中时的箭头图标，节省左侧空间（可选）
          selection_caret = '  ',
          -- 或者用更显眼的图标:
          -- selection_caret = "> ",
        },
      }

      -- Enable the native sorter when available.
      pcall(require('telescope').load_extension, 'fzf')
    end,
  }, -- LSP Plugins
  {
    -- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
    -- used for completion, annotations and signatures of Neovim apis
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = { -- Load luvit types when the `vim.uv` word is found
        {
          path = '${3rd}/luv/library',
          words = { 'vim%.uv' },
        },
      },
    },
  },
  {
    -- Main LSP Configuration
    'neovim/nvim-lspconfig',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      {
        'j-hui/fidget.nvim',
        opts = {},
      }, -- Allows extra capabilities provided by blink.cmp
      'saghen/blink.cmp',
    },
    config = function()
      -- Thus, Language Servers are external tools that must be available on PATH through Mise.

      --  This function gets run when an LSP attaches to a particular buffer.
      --    That is to say, every time a new file is opened that is associated with
      --    an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
      --    function will be executed to configure the current buffer
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', {
          clear = true,
        }),
        callback = function(event)
          -- NOTE: Remember that Lua is a real programming language, and as such it is possible
          -- to define small helper and utility functions so you don't have to repeat yourself.
          --
          -- In this case, we create a function that lets us more easily define mappings specific
          -- for LSP related items. It sets the mode, buffer and description for us each time.
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, {
              buffer = event.buf,
              desc = 'LSP: ' .. desc,
            })
          end

          local telescope = function(picker)
            return function()
              require('telescope.builtin')[picker]()
            end
          end

          map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
          map('<leader>ca', vim.lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' })
          map('gr', telescope 'lsp_references', '[G]oto [R]eferences')
          map('gi', telescope 'lsp_implementations', '[G]oto [I]mplementation')
          map('gd', telescope 'lsp_definitions', '[G]oto [D]efinition')
          map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
          map('gT', telescope 'lsp_type_definitions', '[G]oto [T]ype Definition')
          map('<leader>sO', telescope 'lsp_document_symbols', 'Open Document Symbols')
          map('<leader>sW', telescope 'lsp_dynamic_workspace_symbols', '[S]ymbols [W]orkspace')
          map('K', vim.lsp.buf.hover, 'Hover Documentation')
          map('<leader>e', vim.diagnostic.open_float, 'Show Line Diagnostics')

          -- The following two autocommands are used to highlight references of the
          -- word under your cursor when your cursor rests there for a little while.
          --    See `:help CursorHold` for information about when this is executed
          --
          -- When you move your cursor, the highlights will be cleared (the second autocommand).
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
            local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', {
              clear = false,
            })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd('LspDetach', {
              group = vim.api.nvim_create_augroup('kickstart-lsp-detach', {
                clear = true,
              }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds {
                  group = 'kickstart-lsp-highlight',
                  buffer = event2.buf,
                }
              end,
            })
          end

          -- The following code creates a keymap to toggle inlay hints in your
          -- code, if the language server you are using supports them
          --
          -- This may be unwanted, since they displace some of your code
          if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
            map('<leader>ti', function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled {
                bufnr = event.buf,
              })
            end, '[T]oggle Inlay h[i]nts')
          end
        end,
      })

      -- Diagnostic Config
      -- See :help vim.diagnostic.Opts
      vim.diagnostic.config {
        severity_sort = true,

        float = {
          border = 'rounded',
          source = 'if_many',
          severity = vim.diagnostic.severity.WARN,
        },

        underline = {
          severity = vim.diagnostic.severity.WARN,
        },

        signs = vim.g.have_nerd_font and {
          severity = vim.diagnostic.severity.WARN,
          text = {
            [vim.diagnostic.severity.ERROR] = '󰅚 ',
            [vim.diagnostic.severity.WARN] = '󰀪 ',
            [vim.diagnostic.severity.INFO] = '󰋽 ',
            [vim.diagnostic.severity.HINT] = '󰌶 ',
          },
        } or {},

        virtual_text = {
          source = 'if_many',
          spacing = 2,
          -- severity = vim.diagnostic.severity.WARN,
          format = function(diagnostic)
            local diagnostic_message = {
              [vim.diagnostic.severity.ERROR] = diagnostic.message,
              [vim.diagnostic.severity.WARN] = diagnostic.message,
              [vim.diagnostic.severity.INFO] = diagnostic.message,
              [vim.diagnostic.severity.HINT] = diagnostic.message,
            }
            return diagnostic_message[diagnostic.severity]
          end,
        },
      }

      -- LSP servers and clients are able to communicate to each other what features they support.
      --  By default, Neovim doesn't support everything that is in the LSP specification.
      --  blink.cmp adds completion capabilities to the native LSP client.
      --  So, we create new capabilities with blink.cmp, and then broadcast that to the servers.
      local capabilities = require('blink.cmp').get_lsp_capabilities()

      -- Enable the following language servers. Their executables are managed by Mise.
      --
      --  Add any additional override configuration in the following tables. Available keys are:
      --  - cmd (table): Override the default command used to start the server
      --  - filetypes (table): Override the default list of associated filetypes for the server
      --  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
      --  - settings (table): Override the default settings passed when initializing the server.
      --        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
      local servers = {
        -- Lua Language Server
        lua_ls = {
          settings = {
            Lua = {
              completion = {
                callSnippet = 'Replace',
              },
              -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
              -- diagnostics = { disable = { 'missing-fields' } },
            },
          },
        },

        gopls = {
          settings = {
            gopls = {
              buildFlags = { '-tags=integration,integration_unittest,legacy_integration' },
            },
          },
        },
      }

      for server_name, server in pairs(servers or {}) do
        server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
        vim.lsp.config(server_name, server)
        vim.lsp.enable(server_name)
      end
    end,
  },
  { -- Autoformat
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {
      {
        '<leader>f',
        function()
          require('conform').format { async = true, lsp_format = 'fallback' }
        end,
        mode = '',
        desc = '[F]ormat buffer',
      },
    },
    opts = {
      notify_on_error = false,
      format_on_save = function(bufnr)
        -- Disable "format_on_save lsp_fallback" for languages that don't
        -- have a well standardized coding style. You can add additional
        -- languages here or re-enable it for the disabled ones.
        local disable_filetypes = {
          c = true,
          cpp = true,
        }
        if disable_filetypes[vim.bo[bufnr].filetype] then
          return nil
        else
          local timeout_ms = 500
          if vim.bo[bufnr].filetype == 'go' then
            timeout_ms = 2000
          end
          return {
            timeout_ms = timeout_ms,
            lsp_format = 'fallback',
          }
        end
      end,
      formatters_by_ft = {
        lua = { 'stylua' },
        go = { 'goimports', 'gofumpt' },
      },
      formatters = {},
    },
  },
  { -- Autocompletion
    'saghen/blink.cmp',
    event = 'InsertEnter',
    version = '1.*',
    dependencies = { 'folke/lazydev.nvim' },
    --- @module 'blink.cmp'
    --- @type blink.cmp.Config
    opts = {
      keymap = {
        preset = 'default',
      },

      appearance = {
        -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
        -- Adjusts spacing to ensure icons are aligned
        nerd_font_variant = 'mono',
      },

      completion = {
        -- By default, you may press `<c-space>` to show the documentation.
        -- Optionally, set `auto_show = true` to show the documentation after a delay.
        documentation = {
          auto_show = false,
          auto_show_delay_ms = 500,
        },
      },

      sources = {
        default = { 'lsp', 'path', 'snippets', 'lazydev' },
        providers = {
          lazydev = {
            module = 'lazydev.integrations.blink',
            score_offset = 100,
          },
        },
      },

      fuzzy = {
        implementation = 'lua',
      },

      -- Shows a signature help window while you type arguments for a function
      signature = {
        enabled = true,
      },
    },
  },
  {
    'folke/todo-comments.nvim',
    event = 'VimEnter',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = {
      signs = false,
    },
  },
  { -- Collection of various small independent plugins/modules
    'echasnovski/mini.nvim',
    event = 'VeryLazy',
    config = function()
      require('mini.ai').setup {
        n_lines = 500,
      }
    end,
  },
  { -- Highlight and indent with Neovim's native Treesitter APIs
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    lazy = false,
    build = ':TSUpdate',
    config = function()
      local treesitter = require 'nvim-treesitter'
      treesitter.setup {
        install_dir = vim.fn.stdpath 'data' .. '/site',
      }

      local parsers = {
        'bash',
        'c',
        'diff',
        'go',
        'html',
        'lua',
        'luadoc',
        'markdown',
        'markdown_inline',
        'python',
        'query',
        'vim',
        'vimdoc',
      }

      vim.treesitter.language.register('bash', 'sh')

      local function parser_available(lang)
        return #vim.api.nvim_get_runtime_file('parser/' .. lang .. '.*', false) > 0
      end

      local function attach(bufnr)
        if not vim.api.nvim_buf_is_valid(bufnr) or not vim.api.nvim_buf_is_loaded(bufnr) then
          return
        end

        local filetype = vim.bo[bufnr].filetype
        local lang = vim.treesitter.language.get_lang(filetype)
        if not lang or not parser_available(lang) then
          return
        end

        if not vim.treesitter.highlighter.active[bufnr] then
          vim.treesitter.start(bufnr, lang)
        end
        if filetype == 'ruby' then
          vim.bo[bufnr].syntax = 'ON'
        else
          vim.bo[bufnr].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
      end

      vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup('treesitter-start', { clear = true }),
        callback = function(event)
          attach(event.buf)
        end,
      })

      local installed = {}
      for _, parser in ipairs(treesitter.get_installed 'parsers') do
        installed[parser] = true
      end
      local missing = vim.tbl_filter(function(parser)
        return not installed[parser]
      end, parsers)
      if #missing > 0 then
        if vim.fn.executable 'tree-sitter' == 0 then
          vim.notify('Treesitter parsers are missing; run `mise install` first', vim.log.levels.WARN)
        else
          treesitter.install(missing, { summary = false }):await(function(err, success)
            vim.schedule(function()
              if err or not success then
                vim.notify('Some Treesitter parsers failed to install', vim.log.levels.WARN)
              end
              for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
                attach(bufnr)
              end
            end)
          end)
        end
      end
    end,
  },
  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    branch = 'main',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    event = { 'BufReadPost', 'BufNewFile' },
    config = function()
      require('nvim-treesitter-textobjects').setup {
        select = { lookahead = true },
        move = { set_jumps = true },
      }

      local select = require 'nvim-treesitter-textobjects.select'
      local swap = require 'nvim-treesitter-textobjects.swap'
      local move = require 'nvim-treesitter-textobjects.move'

      local function map(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { desc = desc, silent = true })
      end

      local selections = {
        { 'af', '@function.outer', 'Select outer function' },
        { 'if', '@function.inner', 'Select inner function' },
        { 'ac', '@class.outer', 'Select outer class' },
        { 'ic', '@class.inner', 'Select inner class' },
        { 'aC', '@call.outer', 'Select outer call' },
        { 'iC', '@call.inner', 'Select inner call' },
        { 'ad', '@conditional.outer', 'Select outer conditional' },
        { 'id', '@conditional.inner', 'Select inner conditional' },
        { 'al', '@loop.outer', 'Select outer loop' },
        { 'il', '@loop.inner', 'Select inner loop' },
      }
      for _, selection in ipairs(selections) do
        map({ 'x', 'o' }, selection[1], function()
          select.select_textobject(selection[2], 'textobjects')
        end, selection[3])
      end

      map('n', '<leader>a', function()
        swap.swap_next '@parameter.inner'
      end, 'Swap with next parameter')
      map('n', '<leader>A', function()
        swap.swap_previous '@parameter.inner'
      end, 'Swap with previous parameter')

      local motions = {
        { ']m', move.goto_next_start, '@function.outer', 'Next function start' },
        { ']]', move.goto_next_start, '@class.outer', 'Next class start' },
        { ']M', move.goto_next_end, '@function.outer', 'Next function end' },
        { '][', move.goto_next_end, '@class.outer', 'Next class end' },
        { '[m', move.goto_previous_start, '@function.outer', 'Previous function start' },
        { '[[', move.goto_previous_start, '@class.outer', 'Previous class start' },
        { '[M', move.goto_previous_end, '@function.outer', 'Previous function end' },
        { '[]', move.goto_previous_end, '@class.outer', 'Previous class end' },
      }
      for _, motion in ipairs(motions) do
        map({ 'n', 'x', 'o' }, motion[1], function()
          motion[2](motion[3], 'textobjects')
        end, motion[4])
      end
    end,
  },
  require 'kickstart.plugins.debug',
  require 'kickstart.plugins.indent_line',
  require 'kickstart.plugins.lint',
  require 'kickstart.plugins.autopairs',
  require 'kickstart.plugins.neo-tree',
  -- NOTE: Custom plugins are organized into categories and auto-imported from lua/custom/plugins/
  -- Each category has its own directory for better organization and maintainability.
  { import = 'custom.plugins.git' },
  { import = 'custom.plugins.ui-enhancement' },
  { import = 'custom.plugins.navigation' },
  { import = 'custom.plugins.editing' },
  { import = 'custom.plugins.terminal' },
  { import = 'custom.plugins.language-specific' },
  { import = 'custom.plugins.utils' },
  { import = 'custom.plugins.session' },
  require 'custom.base46', -- Base46 theme system
}, {
  rocks = {
    enabled = false,
  },
  ui = {
    -- If you are using a Nerd Font: set icons to an empty table which will use the
    -- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
})

-- vim: ts=2 sts=2 sw=2 et

require 'custom.keymaps'
