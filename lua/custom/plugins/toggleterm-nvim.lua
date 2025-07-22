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
