-- alpha.nvim 是一个启动页面插件
return {
  'goolord/alpha-nvim',
  dependencies = { 'echasnovski/mini.icons', 'nvim-lua/plenary.nvim' },
  config = function()
    local alpha = require 'alpha'
    local dashboard = require 'alpha.themes.dashboard'

    -- 1. 随机 ASCII 艺术头图 (Fallback)
    local headers = {
      {
        [[   ⣴⣶⣤⡤⠦⣤⣀⣤⠆     ⣈⣭⣿⣶⣿⣦⣼⣆          ]],
        [[    ⠉⠻⢿⣿⠿⣿⣿⣶⣦⠤⠄⡈⠛⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣦      ]],
        [[          ⠈⠻⣿⣿⣿⣿⣷⣶⣦⣤⣈⣿⣿⣿⣿⣿⣿⣿⣷⡄     ]],
        [[  ⢠⣾⢷⣾⣷⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⡆    ]],
        [[  ⠘⢿⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇    ]],
        [[   ⠈⠛⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇    ]],
        [[     ⠈⢿⣿⣆⠈⠛⠛⠛⠿⠿⠿⠿⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇    ]],
        [[      ⠘⣿⣿⣧⡀         ⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇    ]],
        [[       ⠘⣿⣿⣷⣄       ⢀⣼⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇    ]],
        [[        ⠹⣿⣿⣿⣷⣄    ⢀⣴⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇    ]],
        [[         ⠹⣿⣿⣿⣿⣷⣄ ⢀⣴⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇    ]],
        [[          ⠹⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇    ]],
        [[           ⠹⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇    ]],
        [[            ⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉    ]],
      },
    }

    -- 2. 随机名言/格言
    local quotes = {
      { '"The only way to do great work is to love what you do."', '- Steve Jobs' },
      { '"Talk is cheap. Show me the code."', '- Linus Torvalds' },
      { '"Programs must be written for people to read, and only incidentally for machines to execute."', '- Abelson & Sussman' },
      { '"Simplicity is the soul of efficiency."', '- Austin Freeman' },
      { '"Code is like humor. When you have to explain it, it’s bad."', '- Cory House' },
      { '"First, solve the problem. Then, write the code."', '- John Johnson' },
      { '"Make it work, make it right, make it fast."', '- Kent Beck' },
    }

    local function get_random_element(tbl)
      math.randomseed(os.time())
      return tbl[math.random(#tbl)]
    end

    local quote = get_random_element(quotes)

    -- 3. 动态问候语
    local function get_greeting()
      local hour = tonumber(os.date '%H')
      if hour >= 5 and hour < 12 then
        return 'Good Morning, Developer!'
      elseif hour >= 12 and hour < 18 then
        return 'Good Afternoon, Developer!'
      elseif hour >= 18 and hour < 22 then
        return 'Good Evening, Developer!'
      else
        return 'Late Night Coding?'
      end
    end

    -- 4. Cowsay (带增强 Fallback)
    local function command_exists(cmd)
      local handle = io.popen('which ' .. cmd .. ' 2>/dev/null')
      if handle then
        local result = handle:read '*a'
        handle:close()
        return result ~= ''
      end
      return false
    end

    local function get_header()
      -- 尝试使用 fortune | cowsay
      if command_exists 'fortune' and command_exists 'cowsay' then
        local handle = io.popen "fortune -s | cowsay -f $(cowsay -l | tail -n +2 | tr ' ' '\\n' | gshuf -n1)"
        if handle then
          local result = handle:read '*a'
          handle:close()
          if result and result ~= '' then
            return vim.split(result, '\n')
          end
        end
      end

      -- 如果没有 fortune，尝试用 cowsay 说我们的名言
      if command_exists 'cowsay' then
        local cow_cmd = string.format("cowsay -f $(cowsay -l | tail -n +2 | tr ' ' '\\n' | gshuf -n1) '%s'", quote[1] .. ' ' .. quote[2])
        local handle = io.popen(cow_cmd)
        if handle then
          local result = handle:read '*a'
          handle:close()
          if result and result ~= '' then
            return vim.split(result, '\n')
          end
        end
      end

      -- 如果都没有，使用随机 ASCII 艺术
      return get_random_element(headers)
    end

    dashboard.section.header.val = get_header()
    dashboard.section.header.opts.hl = 'AlphaHeader'

    -- 5. 按钮列表
    dashboard.section.buttons.val = {
      dashboard.button('r', '  Recent Files', ':Telescope oldfiles only_cwd=true<CR>'),
      dashboard.button('f', '  Find Files', ':Telescope find_files<CR>'),
      dashboard.button('g', '  Fuzzy Grep', ':Telescope live_grep<CR>'),
      dashboard.button('s', '  Restore Session', ':SessionRestore<CR>'),
      dashboard.button('n', '  New File', ':ene <BAR> startinsert<CR>'),
      dashboard.button('c', '  Configuration', ':e $MYVIMRC<CR>'),
      dashboard.button('u', '  Update Plugins', ':Lazy update<CR>'),
      dashboard.button('q', '  Quit', '<cmd>q!<cr>'),
    }

    -- 6. 底部状态栏 (显示版本、插件数、启动时间、问候语)
    local function footer()
      local stats = require('lazy').stats()
      local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
      local version = vim.version()
      local v = version.major .. '.' .. version.minor .. '.' .. version.patch

      return {
        ' ',
        get_greeting(),
        ' ',
        '⚡ Neovim v' .. v .. '  loaded ' .. stats.loaded .. '/' .. stats.count .. ' plugins in ' .. ms .. 'ms',
      }
    end

    dashboard.section.footer.val = footer()
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
    vim.api.nvim_create_user_command('Dashboard', 'Alpha', { desc = 'Open Dashborad.' })
  end,
}
