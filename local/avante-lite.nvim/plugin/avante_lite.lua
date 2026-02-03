if vim.g.loaded_avante_lite == 1 then return end
vim.g.loaded_avante_lite = 1

---@param opts vim.api.keyset.user_command.callback
local function cmd_ask(opts)
  local question = vim.trim(opts.args or "")
  if question == "" then question = nil end

  require("avante_lite").ask({
    question = question,
    line1 = opts.line1,
    line2 = opts.line2,
    use_range = (opts.range or 0) > 0,
  })
end

vim.api.nvim_create_user_command("AvanteLiteAsk", cmd_ask, {
  nargs = "*",
  range = true,
  desc = "avante-lite: ask with optional selection range",
})

vim.api.nvim_create_user_command("AvanteLiteAskVisual", function()
  require("avante_lite").ask({ use_visual = true })
end, {
  desc = "avante-lite: ask with current visual selection",
})

vim.api.nvim_create_user_command("AvanteLiteStop", function() require("avante_lite").stop() end, {
  desc = "avante-lite: stop current request",
})

vim.api.nvim_create_user_command("AvanteLiteClear", function() require("avante_lite").clear() end, {
  desc = "avante-lite: clear sidebar and reset session",
})
