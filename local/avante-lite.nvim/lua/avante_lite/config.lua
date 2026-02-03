local M = {}

M.defaults = {
  openai = {
    api_key_env = "OPENAI_API_KEY",
    endpoint = "https://api.openai.com/v1/chat/completions",
    model = "gpt-4o-mini",
    temperature = 0.2,
    max_tokens = 1024,
    timeout_ms = 60000,
  },
  ui = {
    -- "left" | "right"
    position = "right",
    width = 50,
    filetype = "markdown",
    buffer_name = "AVANTE_LITE",
  },
  prompt = {
    system = "You are an expert coding assistant. Answer clearly and concisely.",
  },
}

---@param user_opts? table
function M.merge(user_opts)
  return vim.tbl_deep_extend("force", vim.deepcopy(M.defaults), user_opts or {})
end

return M

