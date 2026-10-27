local M = {}
local scope = 'project'
local choices = { 'project', 'folder', 'open files' }

function M.choose()
  vim.ui.select(choices, { prompt = 'Search scope (current: ' .. scope .. ')' }, function(choice)
    if choice then
      scope = choice
      vim.notify('Search scope: ' .. scope)
    end
  end)
end

function M.search(kind)
  local folder = vim.bo.buftype == '' and vim.fs.dirname(vim.api.nvim_buf_get_name(0)) or nil
  local cwd = (scope == 'folder' and folder) or vim.fs.root(0, { '.git', 'go.mod', 'package.json' }) or vim.fn.getcwd()
  local opts = { cwd = cwd, prompt_title = ({ find_files = 'Files', live_grep = 'Grep', grep_string = 'Word' })[kind] .. ' · ' .. scope .. ' · ' .. cwd }
  local builtin = require 'telescope.builtin'
  if scope == 'open files' then
    if kind == 'find_files' then
      builtin.buffers { prompt_title = 'Files · open buffers', sort_mru = true, ignore_current_buffer = false }
      return
    end
    opts.search_dirs = {}
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      local name = vim.api.nvim_buf_get_name(buf)
      if vim.bo[buf].buflisted and vim.bo[buf].buftype == '' and name ~= '' and vim.fn.filereadable(name) == 1 then
        opts.search_dirs[#opts.search_dirs + 1] = name
      end
    end
    if #opts.search_dirs == 0 then
      vim.notify 'No saved open files to search'
      return
    end
  end
  builtin[kind](opts)
end

function M.setup()
  vim.keymap.set('n', '<leader>sS', M.choose, { desc = 'Choose file / grep search scope' })
end

return M
