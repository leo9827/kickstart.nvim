return {
  'lewis6991/gitsigns.nvim',
  event = 'BufReadPre',
  opts = {
    sign_priority = 6,
    signs = {
      add = { text = '+' },
      change = { text = '~' },
      delete = { text = '_' },
      topdelete = { text = '‾' },
      changedelete = { text = '~' },
    },
    on_attach = function(bufnr)
      local gitsigns = require 'gitsigns'

      local function map(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
      end

      local function navigate(direction)
        local beacon = require 'custom.jump_beacon'
        if vim.wo.diff then
          beacon.after(function()
            vim.cmd.normal { direction == 'next' and ']c' or '[c', bang = true }
          end)
          return
        end
        local winid = vim.api.nvim_get_current_win()
        local before = vim.api.nvim_win_get_cursor(winid)
        gitsigns.nav_hunk(direction, nil, function(err)
          if
            not err
            and vim.api.nvim_get_current_win() == winid
            and vim.api.nvim_get_current_buf() == bufnr
            and not vim.deep_equal(before, vim.api.nvim_win_get_cursor(winid))
          then
            beacon.pulse()
          end
        end)
      end
      map('n', ']c', function()
        navigate 'next'
      end, 'Next git change')
      map('n', '[c', function()
        navigate 'prev'
      end, 'Previous git change')

      map('v', '<leader>hs', function()
        gitsigns.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
      end, 'Git: stage hunk')
      map('v', '<leader>hr', function()
        gitsigns.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
      end, 'Git: reset hunk')
      map('n', '<leader>hs', gitsigns.stage_hunk, 'Git: stage hunk')
      map('n', '<leader>hr', gitsigns.reset_hunk, 'Git: reset hunk')
      map('n', '<leader>hS', gitsigns.stage_buffer, 'Git: stage buffer')
      map('n', '<leader>hu', gitsigns.undo_stage_hunk, 'Git: undo staged hunk')
      map('n', '<leader>hR', gitsigns.reset_buffer, 'Git: reset buffer')
      map('n', '<leader>hp', gitsigns.preview_hunk, 'Git: preview hunk')
      map('n', '<leader>hP', gitsigns.preview_hunk_inline, 'Git: preview hunk inline')
      map('n', '<leader>hb', gitsigns.blame_line, 'Git: blame line')
      map('n', '<leader>hd', gitsigns.diffthis, 'Git: diff against index')
      map('n', '<leader>hD', function()
        gitsigns.diffthis '@'
      end, 'Git: diff against last commit')
      map('n', '<leader>tb', gitsigns.toggle_current_line_blame, 'Toggle git blame line')
      map('n', '<leader>tD', gitsigns.toggle_deleted, 'Toggle deleted lines')
    end,
  },
}
