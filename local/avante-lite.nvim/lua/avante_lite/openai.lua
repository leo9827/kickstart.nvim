local M = {}

---@class AvanteLiteOpenAIRequest
---@field endpoint string
---@field api_key string
---@field model string
---@field temperature number
---@field max_tokens integer
---@field timeout_ms integer
---@field messages {role:"system"|"user"|"assistant", content:string}[]

---@param req AvanteLiteOpenAIRequest
---@param cb fun(err: string|nil, content: string|nil): nil
---@return integer|nil job_id
function M.chat(req, cb)
  cb = cb or function() end

  if vim.fn.executable("curl") ~= 1 then
    cb("`curl` not found in PATH", nil)
    return nil
  end

  if not req.api_key or req.api_key == "" then
    cb("Missing OpenAI API key (set env " .. tostring(req.api_key_env or "OPENAI_API_KEY") .. ")", nil)
    return nil
  end

  local body = vim.json.encode({
    model = req.model,
    messages = req.messages,
    temperature = req.temperature,
    max_tokens = req.max_tokens,
    stream = false,
  })

  local timeout_s = math.max(1, math.floor((req.timeout_ms or 60000) / 1000))

  local cmd = {
    "curl",
    "-sS",
    "--max-time",
    tostring(timeout_s),
    "-X",
    "POST",
    req.endpoint,
    "-H",
    "Content-Type: application/json",
    "-H",
    "Authorization: Bearer " .. req.api_key,
    "-d",
    body,
  }

  local stdout = {}
  local stderr = {}

  local job_id = vim.fn.jobstart(cmd, {
    stdout_buffered = true,
    stderr_buffered = true,
    on_stdout = function(_, data)
      if not data then return end
      vim.list_extend(stdout, data)
    end,
    on_stderr = function(_, data)
      if not data then return end
      vim.list_extend(stderr, data)
    end,
    on_exit = function(_, code)
      if code ~= 0 then
        local msg = table.concat(stderr, "\n")
        if msg == "" then msg = "curl exited with code " .. tostring(code) end
        cb(msg, nil)
        return
      end

      local raw = table.concat(stdout, "\n")
      local ok, decoded = pcall(vim.json.decode, raw)
      if not ok then
        cb("Failed to decode JSON response", nil)
        return
      end

      if decoded.error and decoded.error.message then
        cb(decoded.error.message, nil)
        return
      end

      local content = decoded
        and decoded.choices
        and decoded.choices[1]
        and decoded.choices[1].message
        and decoded.choices[1].message.content

      if not content or content == "" then
        cb("Empty response content", nil)
        return
      end

      cb(nil, content)
    end,
  })

  if job_id <= 0 then
    cb("Failed to start curl job", nil)
    return nil
  end

  return job_id
end

return M

