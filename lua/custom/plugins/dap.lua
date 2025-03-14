return {
  'theHamsta/nvim-dap-virtual-text',
  dependencies = {
    'mfussenegger/nvim-dap',
    'nvim-treesitter/nvim-treesitter',
  },
  opts = {
    enabled = true,
    enable_commands = true,
    highlight_changed_variables = true,
    highlight_new_as_changed = false,
    show_stop_reason = true,
    commented = false,
    only_first_definition = true,
    all_references = false,
    clear_on_continue = false,
  },
}
