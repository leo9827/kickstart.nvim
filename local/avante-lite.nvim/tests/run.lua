local function fail(msg)
  vim.api.nvim_err_writeln(msg)
  vim.cmd("cquit")
end

local function assert_eq(actual, expected, msg)
  if actual ~= expected then
    error((msg and (msg .. ": ") or "") .. "expected " .. vim.inspect(expected) .. ", got " .. vim.inspect(actual), 2)
  end
end

local function assert_match(haystack, needle, msg)
  if type(haystack) ~= "string" then error("assert_match haystack must be string", 2) end
  if not haystack:find(needle, 1, true) then
    error((msg and (msg .. ": ") or "") .. "expected to find " .. vim.inspect(needle) .. " in " .. vim.inspect(haystack), 2)
  end
end

local passed, failed, skipped = 0, 0, 0
local function test(name, fn)
  local ok, err = pcall(fn)
  if ok then
    passed = passed + 1
    print("PASS " .. name)
  else
    failed = failed + 1
    vim.api.nvim_err_writeln("FAIL " .. name .. "\n" .. tostring(err))
  end
end

local function itest(name, fn)
  if vim.env.AVANTE_LITE_RUN_INTEGRATION ~= "1" then
    skipped = skipped + 1
    print("SKIP " .. name .. " (set AVANTE_LITE_RUN_INTEGRATION=1)")
    return
  end
  if not vim.env.OPENAI_API_KEY or vim.env.OPENAI_API_KEY == "" then
    skipped = skipped + 1
    print("SKIP " .. name .. " (missing OPENAI_API_KEY)")
    return
  end
  test(name, fn)
end

test("config.merge overrides nested fields", function()
  local Config = require("avante_lite.config")
  local cfg = Config.merge({
    openai = { model = "test-model" },
    ui = { width = 77 },
  })
  assert_eq(cfg.openai.model, "test-model")
  assert_eq(cfg.ui.width, 77)
  assert_eq(type(cfg.openai.temperature), "number")
end)

test("selection.from_range returns expected lines", function()
  local Selection = require("avante_lite.selection")
  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "a", "b", "c" })

  assert_eq(Selection.from_range(bufnr, 1, 1), "a")
  assert_eq(Selection.from_range(bufnr, 2, 3), "b\nc")
  assert_eq(Selection.from_range(bufnr, 3, 3), "c")
end)

test("selection.from_visual (charwise) returns expected text", function()
  local Selection = require("avante_lite.selection")
  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_set_current_buf(bufnr)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "hello world", "second line" })

  vim.cmd("normal! gg0v4l")
  local text = Selection.from_visual(bufnr)
  vim.cmd("normal! <Esc>")

  assert_eq(text, "hello")
end)

test("selection.from_visual (linewise) returns expected lines", function()
  local Selection = require("avante_lite.selection")
  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_set_current_buf(bufnr)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "line1", "line2", "line3" })

  vim.cmd("normal! ggVj")
  local text = Selection.from_visual(bufnr)
  vim.cmd("normal! <Esc>")

  assert_eq(text, "line1\nline2")
end)

test("core.ask builds prompt with selection context and renders output", function()
  local Core = require("avante_lite")
  local Sidebar = require("avante_lite.sidebar")
  local OpenAI = require("avante_lite.openai")

  local orig_sidebar = {
    open = Sidebar.open,
    focus = Sidebar.focus,
    append = Sidebar.append,
    clear = Sidebar.clear,
  }
  local orig_openai_chat = OpenAI.chat

  local appended = {}
  Sidebar.open = function() end
  Sidebar.focus = function() end
  Sidebar.clear = function() appended = {} end
  Sidebar.append = function(lines)
    for _, l in ipairs(lines or {}) do
      table.insert(appended, l)
    end
  end

  local captured_req = nil
  local done = false
  OpenAI.chat = function(req, cb)
    captured_req = req
    vim.defer_fn(function()
      cb(nil, "answer line 1\nanswer line 2")
      done = true
    end, 10)
    return 4242
  end

  Core.setup({ prompt = { system = "SYSTEM" } })

  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_set_current_buf(bufnr)
  vim.api.nvim_buf_set_name(bufnr, "/tmp/avante_lite_test.lua")
  vim.bo[bufnr].filetype = "lua"
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "local x = 1", "return x" })

  Core.ask({ question = "What does this do?", use_range = true, line1 = 1, line2 = 2 })

  vim.wait(2000, function() return done end)

  assert_eq(captured_req.messages[1].role, "system")
  assert_eq(captured_req.messages[1].content, "SYSTEM")
  assert_eq(captured_req.messages[2].role, "user")
  assert_match(captured_req.messages[2].content, "What does this do?")
  assert_match(captured_req.messages[2].content, "Context (selected in /tmp/avante_lite_test.lua):")
  assert_match(captured_req.messages[2].content, "```lua")
  assert_match(captured_req.messages[2].content, "local x = 1")
  assert_match(captured_req.messages[2].content, "return x")

  local joined = table.concat(appended, "\n")
  assert_match(joined, "## User")
  assert_match(joined, "## Assistant")
  assert_match(joined, "answer line 1")
  assert_match(joined, "answer line 2")

  -- restore
  Sidebar.open = orig_sidebar.open
  Sidebar.focus = orig_sidebar.focus
  Sidebar.append = orig_sidebar.append
  Sidebar.clear = orig_sidebar.clear
  OpenAI.chat = orig_openai_chat
end)

test("stop cancels pending request output", function()
  local Core = require("avante_lite")
  local Sidebar = require("avante_lite.sidebar")
  local OpenAI = require("avante_lite.openai")

  local orig_sidebar = {
    open = Sidebar.open,
    focus = Sidebar.focus,
    append = Sidebar.append,
  }
  local orig_openai_chat = OpenAI.chat

  local appended = {}
  Sidebar.open = function() end
  Sidebar.focus = function() end
  Sidebar.append = function(lines)
    for _, l in ipairs(lines or {}) do
      table.insert(appended, l)
    end
  end

  local done = false
  OpenAI.chat = function(_, cb)
    vim.defer_fn(function()
      cb(nil, "SHOULD_NOT_RENDER")
      done = true
    end, 100)
    return 4243
  end

  Core.setup({ prompt = { system = "SYSTEM" } })
  Core.ask({ question = "Q" })
  Core.stop()

  vim.wait(2000, function() return done end)

  local joined = table.concat(appended, "\n")
  assert_match(joined, "(stopped)")
  if joined:find("SHOULD_NOT_RENDER", 1, true) then error("response rendered after stop", 2) end

  Sidebar.open = orig_sidebar.open
  Sidebar.focus = orig_sidebar.focus
  Sidebar.append = orig_sidebar.append
  OpenAI.chat = orig_openai_chat
end)

itest("integration: Core.ask hits OpenAI and renders response", function()
  local Core = require("avante_lite")

  local model = vim.env.AVANTE_LITE_OPENAI_MODEL or "gpt-4o-mini"
  local endpoint = vim.env.AVANTE_LITE_OPENAI_ENDPOINT or "https://api.openai.com/v1/chat/completions"

  Core.setup({
    openai = {
      model = model,
      endpoint = endpoint,
      temperature = 0,
      max_tokens = 32,
      timeout_ms = 20000,
    },
    ui = {
      buffer_name = "AVANTE_LITE_INTEGRATION",
      width = 40,
      position = "right",
    },
    prompt = {
      system = "You are a test assistant. Reply with exactly PONG.",
    },
  })

  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_set_current_buf(bufnr)
  vim.api.nvim_buf_set_name(bufnr, "/tmp/avante_lite_integration_test.lua")
  vim.bo[bufnr].filetype = "lua"
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "local x = 1", "return x" })

  Core.ask({ question = "Reply with exactly PONG.", use_range = true, line1 = 1, line2 = 2 })

  local side_bufnr = vim.fn.bufnr("AVANTE_LITE_INTEGRATION")
  if side_bufnr <= 0 then error("sidebar buffer not created", 2) end

  local ok = vim.wait(30000, function()
    if not vim.api.nvim_buf_is_valid(side_bufnr) then return false end
    local lines = vim.api.nvim_buf_get_lines(side_bufnr, 0, -1, false)
    local joined = table.concat(lines, "\n"):upper()
    return joined:find("PONG", 1, true) ~= nil
  end, 50)
  if not ok then
    local lines = vim.api.nvim_buf_is_valid(side_bufnr) and vim.api.nvim_buf_get_lines(side_bufnr, 0, -1, false) or {}
    error("timed out waiting for OpenAI response; buffer:\n" .. table.concat(lines, "\n"), 2)
  end
end)

if failed > 0 then
  fail(string.format("Tests failed: %d failed, %d passed, %d skipped", failed, passed, skipped))
else
  print(string.format("All tests passed: %d (%d skipped)", passed, skipped))
  vim.cmd("qa")
end
