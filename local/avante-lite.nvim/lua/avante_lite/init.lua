local Config = require("avante_lite.config")
local Sidebar = require("avante_lite.sidebar")
local Selection = require("avante_lite.selection")
local OpenAI = require("avante_lite.openai")

local M = {}

---@class AvanteLiteState
---@field cfg table
---@field messages {role:"system"|"user"|"assistant", content:string}[]
---@field job_id integer?
---@field request_id integer
local state = {
  cfg = Config.merge(nil),
  messages = {},
  job_id = nil,
  request_id = 0,
}

---@param user_opts? table
function M.setup(user_opts)
  state.cfg = Config.merge(user_opts)
  state.messages = {
    { role = "system", content = state.cfg.prompt.system },
  }
end

local function ensure_setup()
  if not state.messages or #state.messages == 0 then M.setup(nil) end
end

---@param question string
---@param selection_text string|nil
---@return string
local function build_user_content(question, selection_text)
  if not selection_text or selection_text == "" then return question end
  local ft = vim.bo.filetype
  local filename = vim.fn.expand("%:p")
  local header = string.format("Context (selected in %s):", filename ~= "" and filename or "[No Name]")
  return table.concat({
    question,
    "",
    header,
    string.format("```%s", ft ~= "" and ft or ""),
    selection_text,
    "```",
  }, "\n")
end

local function start_request(question, selection_text)
  ensure_setup()

  Sidebar.open(state.cfg)
  Sidebar.focus()

  state.request_id = state.request_id + 1
  local request_id = state.request_id

  local user_content = build_user_content(question, selection_text)

  Sidebar.append(vim.list_extend({ "", "## User", "" }, vim.split(user_content, "\n", { plain = true })))
  Sidebar.append({ "" })
  table.insert(state.messages, { role = "user", content = user_content })

  Sidebar.append({ "## Assistant", "", "(requesting...)", "" })

  local api_key = vim.env[state.cfg.openai.api_key_env]
  state.job_id = OpenAI.chat({
    endpoint = state.cfg.openai.endpoint,
    api_key = api_key,
    api_key_env = state.cfg.openai.api_key_env,
    model = state.cfg.openai.model,
    temperature = state.cfg.openai.temperature,
    max_tokens = state.cfg.openai.max_tokens,
    timeout_ms = state.cfg.openai.timeout_ms,
    messages = state.messages,
  }, function(err, content)
    if request_id ~= state.request_id then return end
    state.job_id = nil
    if err then
      Sidebar.append({ "Error: " .. err, "" })
      return
    end

    table.insert(state.messages, { role = "assistant", content = content })
    Sidebar.append(vim.list_extend({}, vim.split(content, "\n", { plain = true })))
    Sidebar.append({ "" })
  end)
end

---@param opts? {question?: string, line1?: integer, line2?: integer, use_range?: boolean, use_visual?: boolean}
function M.ask(opts)
  opts = opts or {}
  ensure_setup()

  local bufnr = vim.api.nvim_get_current_buf()

  local selection_text = nil
  if opts.use_visual then
    selection_text = Selection.from_visual(bufnr)
  elseif opts.use_range and opts.line1 and opts.line2 then
    selection_text = Selection.from_range(bufnr, opts.line1, opts.line2)
  end

  if opts.question and opts.question ~= "" then
    start_request(opts.question, selection_text)
    return
  end

  vim.ui.input({ prompt = "AvanteLite Ask: " }, function(input)
    if not input or input == "" then return end
    start_request(input, selection_text)
  end)
end

function M.stop()
  if not state.job_id then return end
  state.request_id = state.request_id + 1
  pcall(vim.fn.jobstop, state.job_id)
  state.job_id = nil
  Sidebar.append({ "", "(stopped)", "" })
end

function M.clear()
  if state.job_id then
    state.request_id = state.request_id + 1
    pcall(vim.fn.jobstop, state.job_id)
    state.job_id = nil
  end
  Sidebar.open(state.cfg)
  Sidebar.clear()
  state.messages = {
    { role = "system", content = state.cfg.prompt.system },
  }
end

return M
