-- toggleterm 是一个管理 neovim 终端的插件。
-- 它提供了便捷的终端管理功能，可以在编码时快速打开/关闭终端进行命令操作。
--
-- 主要功能：
-- 1. 支持多种终端窗口形式：浮动窗口、水平分割、垂直分割
-- 2. 支持多个终端实例的管理
-- 3. 集成 lazygit 等终端程序
-- 4. 自定义终端行为和外观
--
-- 常用快捷键：
-- * <c-\>    - 打开/关闭上一次使用的终端
-- * <leader>tt - 打开/关闭一个水平分割的终端 (ID: 1)
-- * <leader>tf - 打开/关闭一个浮动终端 (ID: 2)
-- * <leader>tl - 打开/关闭 lazygit
--
-- 在终端中的快捷键：
-- * <esc> 或 jk - 从终端模式切换到普通模式
-- * <c-h/j/k/l> - 在窗口间移动
--
-- 使用场景：
-- 1. 需要执行 git 操作时使用 lazygit
-- 2. 需要执行简单命令而不想切换到外部终端
-- 3. 需要在编码时查看命令输出结果
-- 4. 运行和调试项目

return {
  'akinsho/toggleterm.nvim',
  version = '*',
  config = function()
    -- 主配置
    require('toggleterm').setup {
      -- 按下 <c-\> 会打开/关闭上一次使用的终端
      open_mapping = [[<c-\>]],
      -- 默认打开浮动窗口
      -- direction = 'float',
      -- 浮动窗口的配置
      float_opts = {
        -- 你可以自定义边框样式
        border = 'single', -- 'single', 'double', 'rounded', 'solid', 'shadow'
        winblend = 3,
      },
      -- 非浮动窗口（水平或垂直分割）的大小
      -- 可以是数字（行数/列数），也可以是0到1之间的小数（占屏幕的百分比）
      size = 10,
      -- 当终端失去焦点时，使其背景变暗（推荐）
      shade_terminals = true,
      -- 打开终端时立即进入插入模式
      start_in_insert = true,
      -- 在 Normal 模式下，按 Esc 键关闭终端窗口
      close_on_exit = true,
    }

    local Terminal = require('toggleterm.terminal').Terminal
    local lazygit = Terminal:new { cmd = 'lazygit', direction = 'float', hidden = true }
    local function _toggleterm_lazygit()
      lazygit:toggle()
    end
    vim.keymap.set('n', '<leader>tl', _toggleterm_lazygit, { noremap = true, silent = true, desc = 'Using toggleterm open lazygit' })

    -- 自定义快捷键函数
    local function set_keymaps()
      local opts = { noremap = true, silent = true }

      -- 定义一个函数来创建和切换特定ID的终端
      -- :ToggleTerm<CR> 是一个通用的切换命令
      -- :ToggleTerm direction=... 会打开一个特定方向的终端
      -- :<count>ToggleTerm<CR> 会打开/切换到指定ID的终端
      -- 例如 5ToggleTerm 会打开/切换到ID为5的终端

      -- <leader>tn -> 打开/切换一个水平分割的终端 (Normal)
      -- 我们给它一个固定的ID 1
      vim.keymap.set('n', '<leader>tt', '<cmd>1ToggleTerm<CR>', opts)

      -- <leader>tf -> 打开/切换一个浮动终端 (Float)
      -- 我们给它一个固定的ID 2
      vim.keymap.set('n', '<leader>tf', "<cmd>2ToggleTerm direction='float'<CR>", opts)
    end

    set_keymaps()

    -- 在终端窗口中设置快捷键
    -- 当你进入终端的 Normal 模式时 (通过 <C-\><C-n>)，可以按 Esc 或 q 快速退出
    function _G.set_terminal_keymaps()
      local opts = { buffer = 0 }
      vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], opts)
      vim.keymap.set('t', 'jk', [[<C-\><C-n>]], opts) -- 也可以用 jk 代替 Esc
      vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], opts) -- 移动到左边窗口
      vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], opts) -- 移动到下边窗口
      vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], opts) -- 移动到上边窗口
      vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], opts) -- 移动到右边窗口
    end

    -- 当打开终端时，自动运行上面的函数来设置快捷键
    vim.cmd 'autocmd! TermOpen term://* lua set_terminal_keymaps()'
  end,
}
