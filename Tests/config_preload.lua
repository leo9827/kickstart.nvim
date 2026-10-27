-- Simulate a parser becoming available after asynchronous installation.
if vim.env.NVIM_CHECK_CASE ~= 'parser-install' then
  return
end

_G.ts_parser_ready = false
local runtime_file = vim.api.nvim_get_runtime_file
vim.api.nvim_get_runtime_file = function(name, all)
  if name == 'parser/python.*' then
    return _G.ts_parser_ready and { 'parser/python.so' } or {}
  end
  return runtime_file(name, all)
end
local start = vim.treesitter.start
vim.treesitter.start = function(buf, lang)
  if lang == 'python' then
    vim.b[buf].ts_test_attached = true
  else
    start(buf, lang)
  end
end
package.preload['nvim-treesitter'] = function()
  return {
    setup = function() end,
    get_installed = function()
      return {}
    end,
    install = function()
      return {
        await = function(_, callback)
          _G.ts_install_done = callback
        end,
      }
    end,
    indentexpr = function()
      return 0
    end,
  }
end
