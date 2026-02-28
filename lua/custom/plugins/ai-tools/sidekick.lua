local ai_toggle = require 'custom.ai_tools_toggle'

local function with_sidekick(fn, opts)
  return ai_toggle.guard('sidekick', fn, opts)
end

return {
  'folke/sidekick.nvim',
  opts = {
    -- add any options here
    cli = {
      mux = {
        backend = 'zellij',
        enabled = true,
      },
    },
  },
  keys = {
    {
      '<tab>',
      with_sidekick(function()
        -- if there is a next edit, jump to it, otherwise apply it if any
        if not require('sidekick').nes_jump_or_apply() then
          return '<Tab>' -- fallback to normal tab
        end
      end, { fallback = '<Tab>' }),
      expr = true,
      desc = 'Goto/Apply Next Edit Suggestion',
    },
    {
      '<c-.>',
      with_sidekick(function()
        require('sidekick.cli').toggle()
      end),
      desc = 'Sidekick Toggle',
      mode = { 'n', 't', 'i', 'x' },
    },
    {
      '<leader>aa',
      with_sidekick(function()
        require('sidekick.cli').toggle()
      end),
      desc = 'Sidekick Toggle CLI',
    },
    {
      '<leader>as',
      with_sidekick(function()
        require('sidekick.cli').select()
      end),
      -- Or to select only installed tools:
      -- require("sidekick.cli").select({ filter = { installed = true } })
      desc = 'Select CLI',
    },
    {
      '<leader>ad',
      with_sidekick(function()
        require('sidekick.cli').close()
      end),
      desc = 'Detach a CLI Session',
    },
    {
      '<leader>at',
      with_sidekick(function()
        require('sidekick.cli').send { msg = '{this}' }
      end),
      mode = { 'x', 'n' },
      desc = 'Send This',
    },
    {
      '<leader>af',
      with_sidekick(function()
        require('sidekick.cli').send { msg = '{file}' }
      end),
      desc = 'Send File',
    },
    {
      '<leader>av',
      with_sidekick(function()
        require('sidekick.cli').send { msg = '{selection}' }
      end),
      mode = { 'x' },
      desc = 'Send Visual Selection',
    },
    {
      '<leader>ap',
      with_sidekick(function()
        require('sidekick.cli').prompt()
      end),
      mode = { 'n', 'x' },
      desc = 'Sidekick Select Prompt',
    },
    -- Example of a keybinding to open Claude directly
    {
      '<leader>ac',
      with_sidekick(function()
        require('sidekick.cli').toggle { name = 'codex', focus = true }
      end),
      desc = 'Sidekick Toggle Claude',
    },
  },
}
