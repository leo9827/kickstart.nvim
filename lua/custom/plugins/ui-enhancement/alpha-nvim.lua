-- alpha.nvim 是一个启动页面插件
return {
  'goolord/alpha-nvim',
  lazy = true, -- Delay load until needed
  event = 'VimEnter', -- Load on startup
  dependencies = { 'echasnovski/mini.icons', 'nvim-lua/plenary.nvim' },
  config = function()
    local alpha = require 'alpha'
    local dashboard = require 'alpha.themes.dashboard'

    -- 1. 静态 ASCII 艺术头图 (优化: 避免启动时的 io.popen 调用，节省 ~30-40ms)
    local static_header = {
      [[  _______________________________________  ]],
      [[ / The meek shall inherit the earth; the \ ]],
      [[ \ rest of us, the Universe.             / ]],
      [[  ---------------------------------------  ]],
      [[        \                                  ]],
      [[         \                                 ]],
      [[          \                                ]],
      [[       ___       _____     ___             ]],
      [[      /   \     /    /|   /   \            ]],
      [[     |     |   /    / |  |     |           ]],
      [[     |     |  /____/  |  |     |           ]],
      [[     |     |  |    |  |  |     |           ]],
      [[     |     |  | {} | /   |     |           ]],
      [[     |     |  |____|/    |     |           ]],
      [[     |     |    |==|     |     |           ]],
      [[     |      \___________/      |           ]],
      [[     |                         |           ]],
      [[     |                         |           ]],
      [[                                           ]],
    }

    dashboard.section.header.val = static_header
    dashboard.section.header.opts.hl = 'AlphaHeader'

    -- 2. 动态问候语
    local function get_greeting()
      local hour = tonumber(os.date '%H')
      local date = os.date '%Y-%m-%d'
      local day = os.date '%A'
      local greeting = ''

      if hour >= 5 and hour < 12 then
        greeting = '🌅 Good Morning, Developer!'
      elseif hour >= 12 and hour < 18 then
        greeting = '☀️ Good Afternoon, Developer!'
      elseif hour >= 18 and hour < 22 then
        greeting = '🌆 Good Evening, Developer!'
      else
        greeting = '🌙 Late Night Coding?'
      end

      return greeting .. ' (' .. date .. ', ' .. day .. ')'
    end

    -- 3. 按钮列表
    dashboard.section.buttons.val = {
      dashboard.button('r', '  Recent Files', ':Telescope oldfiles only_cwd=true<CR>'),
      dashboard.button('f', '  Find Files', ':Telescope find_files<CR>'),
      dashboard.button('g', '  Fuzzy Grep', ':Telescope live_grep<CR>'),
      dashboard.button('d', '  Git Changes', ':Telescope git_status<CR>'),
      dashboard.button('s', '  Restore Session', ':AutoSession restore<CR>'),
      dashboard.button('n', '  New File', ':ene <BAR> startinsert<CR>'),
      dashboard.button('c', '  Configuration', ':e $MYVIMRC<CR>'),
      dashboard.button('u', '  Update Plugins', ':Lazy update<CR>'),
      dashboard.button('q', '  Quit', '<cmd>q!<cr>'),
    }

    -- 4. 底部状态栏 (显示版本、插件数、启动时间、问候语)
    local function footer()
      local stats = require('lazy').stats()
      local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
      local version = vim.version()
      local v = version.major .. '.' .. version.minor .. '.' .. version.patch

      return {
        ' ',
        get_greeting(),
        ' ',
        '⚡ Neovim v' .. v .. ', loaded ' .. stats.loaded .. '/' .. stats.count .. ' plugins in ' .. ms .. 'ms.',
      }
    end

    dashboard.section.footer.val = footer()
    dashboard.section.footer.opts.hl = 'AlphaFooter'

    dashboard.config.layout = {
      { type = 'padding', val = 1 },
      dashboard.section.header,
      { type = 'padding', val = 1 },
      dashboard.section.buttons,
      { type = 'padding', val = 1 },
      dashboard.section.footer,
    }

    alpha.setup(dashboard.config)
    vim.cmd [[autocmd FileType alpha setlocal nofoldenable]]
    vim.api.nvim_create_user_command('Dashboard', 'Alpha', { desc = 'Open Dashborad.' })
  end,
}
