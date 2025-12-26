-- alpha.nvim 是一个启动页面插件
-- 作用：美化 neovim 的启动界面，提供多种内置主题（如 dashboard、startify、theta 等）
-- 常用场景：
--   - 启动 neovim 时显示美观的欢迎界面
--   - 快速访问最近打开的文件
--   - 显示常用按键绑定提示
--   - 创建新文件或打开项目
-- 常用方式：
--   - 默认在启动时自动显示
--   - 可以通过 :Alpha 命令手动打开启动页面
-- 快捷键（在启动页面中）：
--   - <leader>sl - 打开最后一个会话
--   - <CR> - 选择并执行当前选项
--   - q - 关闭启动页面

return {
  'goolord/alpha-nvim',
  dependencies = {
    'echasnovski/mini.icons',
    'nvim-lua/plenary.nvim',
  },
  config = function()
    require('alpha').setup(require('alpha.themes.theta').config)
    vim.api.nvim_create_user_command('Dashboard', 'Alpha', { desc = 'Open Dashborad.' })

    local alpha = require 'alpha'
    local dashboard = require 'alpha.themes.dashboard'

    local function command_exists(cmd)
      local handle = io.popen('which ' .. cmd .. ' 2>/dev/null')
      if handle then
        local result = handle:read '*a'
        handle:close()
        return result ~= ''
      end
      return false
    end

    local function get_fortune()
      if command_exists 'fortune' and command_exists 'cowsay' then
        local handle = io.popen "fortune -s | cowsay -f $(cowsay -l | tail -n +2 | tr ' ' '\\n' | gshuf -n1)"
        if handle then
          local result = handle:read '*a'
          handle:close()
          return result
        end
      end

      -- if command not found, return default
      return [[
   ╭─────────────────────────────╮
   │         Welcome back!       │
   ╰─────────────────────────────╯
                        ]]
    end

    dashboard.section.header.val = vim.split(get_fortune(), '\n')
    dashboard.section.header.opts.hl = 'AlphaHeader'

    dashboard.section.buttons.val = {
      -- dashboard.button('SPC f r', '  Recent Files', ':Telescope oldfiles<CR>'),
      -- dashboard.button('SPC s f', '  Find Files', '<leader>sf'),
      -- dashboard.button('SPC f g', '  Fuzzy Grep', '<leader>sg'),
      dashboard.button('r', '  Recent Files', ':Telescope oldfiles only_cwd=true<CR>'),
      dashboard.button('f', '  Find Files', ':Telescope find_files<CR>'),
      dashboard.button('g', '  Fuzzy Grep', ':Telescope live_grep<CR>'),
      dashboard.button('n', '  New File', ':ene <BAR> startinsert<CR>'),
      dashboard.button('u', '  Update Plugins', ':Lazy update<CR>'),
      dashboard.button('q', '  Quit', '<cmd>q!<cr>'),
    }

    local function get_day_of_week()
      return os.date '%A'
    end

    dashboard.section.footer.val = {
      get_day_of_week(),
    }
    dashboard.section.footer.opts.hl = 'AlphaFooter'

    dashboard.config.layout = {
      { type = 'padding', val = 2 },
      dashboard.section.header,
      { type = 'padding', val = 2 },
      dashboard.section.buttons,
      { type = 'padding', val = 2 },
      dashboard.section.footer,
    }

    alpha.setup(dashboard.config)
    vim.cmd [[autocmd FileType alpha setlocal nofoldenable]]
  end,
}
