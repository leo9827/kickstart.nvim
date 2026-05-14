return {
  'sindrets/diffview.nvim',
  cmd = { 'DiffviewOpen', 'DiffviewClose', 'DiffviewToggleFiles', 'DiffviewFocusFiles', 'DiffviewFileHistory' },
  keys = {
    { '<leader>gd', '<cmd>DiffviewOpen<cr>', desc = 'Diff working changes' },
    { '<leader>gD', '<cmd>DiffviewOpen --staged<cr>', desc = 'Diff staged changes' },
    { '<leader>gh', '<cmd>DiffviewFileHistory %<cr>', desc = 'File history' },
    { '<leader>gH', '<cmd>DiffviewFileHistory<cr>', desc = 'Branch history' },
    { '<leader>gq', '<cmd>DiffviewClose<cr>', desc = 'Close diff' },
  },
  config = function()
    local actions = require 'diffview.actions'

    require('diffview').setup {
      enhanced_diff_hl = true,
      view = {
        default = { layout = 'diff2_vertical' },
        file_history = { layout = 'diff2_vertical' },
        merge_tool = { layout = 'diff3_mixed' },
      },
      file_panel = {
        listing_style = 'tree',
        tree_options = { flatten_dirs = true },
        win_config = { position = 'left', width = 35 },
      },
      keymaps = {
        view = {
          ['q'] = '<cmd>DiffviewClose<cr>',
          ['<leader>e'] = actions.toggle_files,
          ['[x'] = actions.prev_conflict,
          [']x'] = actions.next_conflict,
        },
        file_panel = {
          ['q'] = '<cmd>DiffviewClose<cr>',
          ['j'] = actions.next_entry,
          ['k'] = actions.prev_entry,
          ['<cr>'] = actions.select_entry,
          ['o'] = actions.select_entry,
          ['s'] = actions.toggle_stage_entry,
          ['-'] = actions.toggle_stage_entry,
          ['S'] = actions.stage_all,
          ['U'] = actions.unstage_all,
          ['R'] = actions.refresh_files,
          ['<leader>e'] = actions.toggle_files,
          ['[x'] = actions.prev_conflict,
          [']x'] = actions.next_conflict,
        },
        file_history_panel = {
          ['q'] = '<cmd>DiffviewClose<cr>',
          ['j'] = actions.next_entry,
          ['k'] = actions.prev_entry,
          ['<cr>'] = actions.select_entry,
          ['o'] = actions.select_entry,
          ['!'] = actions.options,
          ['<leader>e'] = actions.toggle_files,
        },
      },
    }
  end,
}
