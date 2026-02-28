local M = {}

local uv = vim.uv or vim.loop
local notify_state = {
  last_ms = {},
  cooldown_ms = 800,
}

local state = {
  sidekick = false,
  avante = true,
}

local avante_patch = nil
local setup_done = false

local valid_tools = {
  sidekick = true,
  avante = true,
  all = true,
}

local function now_ms()
  if uv and uv.now then
    return uv.now()
  end
  return 0
end

local function normalize_tool(tool)
  local value = (tool or 'all'):lower()
  if valid_tools[value] then
    return value
  end
  return nil
end

local function status_text()
  local sidekick = state.sidekick and 'ENABLED' or 'DISABLED'
  local avante = state.avante and 'ENABLED' or 'DISABLED'
  return ('AI Tools: sidekick=%s, avante=%s'):format(sidekick, avante)
end

local function notify(msg, level)
  vim.notify(msg, level or vim.log.levels.INFO, { title = 'AI Tools' })
end

local function notify_disabled(tool)
  local t = normalize_tool(tool)
  if t == nil or t == 'all' then
    return
  end

  local now = now_ms()
  local last = notify_state.last_ms[t] or 0
  if now - last < notify_state.cooldown_ms then
    return
  end
  notify_state.last_ms[t] = now

  notify(('%s is disabled. Use <leader>t%s to re-enable.'):format(t, t == 'sidekick' and 's' or 'v'), vim.log.levels.WARN)
end

local function block_avante_call()
  notify_disabled 'avante'
  return nil
end

local function patch_avante()
  if avante_patch ~= nil then
    return
  end

  local ok_api, api = pcall(require, 'avante.api')
  local ok_avante, avante = pcall(require, 'avante')
  if not ok_api and not ok_avante then
    return
  end

  avante_patch = {
    api = {},
    avante = {},
  }

  if ok_api then
    for _, fn in ipairs { 'ask', 'edit', 'refresh', 'focus', 'select_model', 'select_history', 'add_current_buffer', 'add_buffer_files', 'zen_mode' } do
      if type(api[fn]) == 'function' then
        avante_patch.api[fn] = api[fn]
        api[fn] = block_avante_call
      end
    end
  end

  if ok_avante then
    if type(avante.toggle) == 'table' then
      avante_patch.avante.toggle = avante.toggle
      avante.toggle = setmetatable({
        api = true,
        debug = block_avante_call,
        selection = block_avante_call,
        suggestion = block_avante_call,
      }, {
        __call = block_avante_call,
      })
    end

    for _, fn in ipairs { 'toggle_sidebar', 'open_sidebar' } do
      if type(avante[fn]) == 'function' then
        avante_patch.avante[fn] = avante[fn]
        avante[fn] = block_avante_call
      end
    end

    if type(avante.close_sidebar) == 'function' then
      pcall(avante.close_sidebar)
    end
  end
end

local function unpatch_avante()
  if avante_patch == nil then
    return
  end

  local ok_api, api = pcall(require, 'avante.api')
  if ok_api then
    for fn, original in pairs(avante_patch.api) do
      api[fn] = original
    end
  end

  local ok_avante, avante = pcall(require, 'avante')
  if ok_avante then
    for fn, original in pairs(avante_patch.avante) do
      avante[fn] = original
    end
  end

  avante_patch = nil
end

local function apply_runtime(tool)
  if tool == 'sidekick' then
    if state.sidekick then
      pcall(function()
        if vim.fn.exists ':Sidekick' == 2 then
          vim.cmd 'Sidekick nes enable'
        end
      end)
    else
      pcall(function()
        if vim.fn.exists ':Sidekick' == 2 then
          vim.cmd 'Sidekick nes disable'
        end
      end)
      pcall(function()
        local cli = require 'sidekick.cli'
        if type(cli.close) == 'function' then
          cli.close { all = true }
        end
      end)
    end
    return
  end

  if tool == 'avante' then
    if state.avante then
      unpatch_avante()
    else
      pcall(function()
        local api = require 'avante.api'
        if type(api.stop) == 'function' then
          api.stop()
        end
      end)
      patch_avante()
      pcall(function() require('avante_lite').stop() end)
      pcall(function() require('avante_lite.sidebar').close() end)
    end
  end
end

local function set_state(tool, enabled, quiet)
  if tool == 'all' then
    state.sidekick = enabled
    state.avante = enabled
    apply_runtime 'sidekick'
    apply_runtime 'avante'
    if not quiet then
      notify(status_text())
    end
    return
  end

  state[tool] = enabled
  apply_runtime(tool)
  if not quiet then
    notify(status_text())
  end
end

function M.is_enabled(tool)
  local t = normalize_tool(tool)
  if t == nil then
    return false
  end
  if t == 'all' then
    return state.sidekick and state.avante
  end
  return state[t]
end

function M.enable(tool, quiet)
  local t = normalize_tool(tool)
  if not t then
    notify('Invalid tool. Use: sidekick | avante | all', vim.log.levels.ERROR)
    return
  end
  set_state(t, true, quiet)
end

function M.disable(tool, quiet)
  local t = normalize_tool(tool)
  if not t then
    notify('Invalid tool. Use: sidekick | avante | all', vim.log.levels.ERROR)
    return
  end
  set_state(t, false, quiet)
end

function M.toggle(tool, quiet)
  local t = normalize_tool(tool)
  if not t then
    notify('Invalid tool. Use: sidekick | avante | all', vim.log.levels.ERROR)
    return
  end

  if t == 'all' then
    local enabled = not (state.sidekick and state.avante)
    set_state('all', enabled, quiet)
    return
  end

  set_state(t, not state[t], quiet)
end

function M.status()
  notify(status_text())
end

function M.guard(tool, fn, opts)
  opts = opts or {}
  return function(...)
    if not M.is_enabled(tool) then
      if opts.notify ~= false then
        notify_disabled(tool)
      end
      return opts.fallback
    end
    return fn(...)
  end
end

function M.setup()
  if setup_done then
    return
  end
  setup_done = true

  vim.api.nvim_create_user_command('AiToolsToggle', function(opts)
    local arg = vim.trim(opts.args or '')
    if arg == '' then
      arg = 'all'
    end
    M.toggle(arg)
  end, {
    nargs = '?',
    complete = function()
      return { 'all', 'sidekick', 'avante' }
    end,
    desc = 'Toggle AI tools (all/sidekick/avante)',
  })

  vim.api.nvim_create_user_command('AiToolsEnable', function(opts)
    local arg = vim.trim(opts.args or '')
    if arg == '' then
      arg = 'all'
    end
    M.enable(arg)
  end, {
    nargs = '?',
    complete = function()
      return { 'all', 'sidekick', 'avante' }
    end,
    desc = 'Enable AI tools (all/sidekick/avante)',
  })

  vim.api.nvim_create_user_command('AiToolsDisable', function(opts)
    local arg = vim.trim(opts.args or '')
    if arg == '' then
      arg = 'all'
    end
    M.disable(arg)
  end, {
    nargs = '?',
    complete = function()
      return { 'all', 'sidekick', 'avante' }
    end,
    desc = 'Disable AI tools (all/sidekick/avante)',
  })

  vim.api.nvim_create_user_command('AiToolsStatus', function()
    M.status()
  end, {
    desc = 'Show AI tools enable/disable status',
  })

  vim.api.nvim_create_autocmd('User', {
    group = vim.api.nvim_create_augroup('AiToolsToggleLazyLoad', { clear = true }),
    pattern = 'LazyLoad',
    callback = function(event)
      local plugin = event and event.data or ''
      if type(plugin) == 'table' then
        plugin = plugin.name or plugin[1] or ''
      end
      plugin = tostring(plugin)

      if plugin:find('avante.nvim', 1, true) and not state.avante then
        vim.schedule(patch_avante)
      elseif plugin:find('sidekick.nvim', 1, true) and not state.sidekick then
        vim.schedule(function()
          apply_runtime 'sidekick'
        end)
      end
    end,
  })
end

return M
