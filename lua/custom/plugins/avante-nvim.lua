return {
  'yetone/avante.nvim',
  event = 'VeryLazy',
  version = false, -- Never set it to '*', Never!
  build = 'make', -- build from source
  ---@module 'avante'
  ---@type avante.Config
  opts = {
    provider = 'copilot',
    -- 可以通过增加 `suggestion.debounce` 来减少请求频率
    auto_suggestions_provider = 'copilot',
    suggestion = {
      debounce = 600,
      throttle = 600,
    },
    providers = {
      copilot = {
        endpoint = 'https://api.githubcopilot.com',
        -- model = 'claude-sonnet-4',
        -- model = 'gemini-2.5-pro',
        model = 'GPT-5.1 mini',
        proxy = nil, -- [protocol://]host[:port] Use this proxy
        allow_insecure = false, -- Allow insecure server connections
        timeout = 30000, -- Timeout in milliseconds
        context_window = 64000, -- Number of tokens to send to the model for context
        extra_request_body = {
          -- temperature = 0.2, -- 越大越发散越随机
          temperature = 0.75,
          max_tokens = 20480,
        },
      },
      ---Specify the behaviour of avante.nvim
      ---1. auto_focus_sidebar              : Whether to automatically focus the sidebar when opening avante.nvim. Default to true.
      ---2. auto_suggestions = false, -- Whether to enable auto suggestions. Default to false.
      ---3. auto_apply_diff_after_generation: Whether to automatically apply diff after LLM response.
      ---                                     This would simulate similar behaviour to cursor. Default to false.
      ---4. auto_set_keymaps                : Whether to automatically set the keymap for the current line. Default to true.
      ---                                     Note that avante will safely set these keymap. See https://github.com/yetone/avante.nvim/wiki#keymaps-and-api-i-guess for more details.
      ---5. auto_set_highlight_group        : Whether to automatically set the highlight group for the current line. Default to true.
      ---6. jump_result_buffer_on_finish = false, -- Whether to automatically jump to the result buffer after generation
      ---7. support_paste_from_clipboard    : Whether to support pasting image from clipboard. This will be determined automatically based whether img-clip is available or not.
      ---8. minimize_diff                   : Whether to remove unchanged lines when applying a code block
      ---9. enable_token_counting           : Whether to enable token counting. Default to true.
    },
    behaviour = {
      auto_focus_sidebar = true,
      auto_suggestions = false, -- Experimental stage
      auto_suggestions_respect_ignore = false,
      auto_set_highlight_group = true,
      auto_set_keymaps = true,
      auto_apply_diff_after_generation = false,
      jump_result_buffer_on_finish = false,
      support_paste_from_clipboard = false,
      minimize_diff = true,
      enable_token_counting = true,
      use_cwd_as_project_root = false,
      auto_focus_on_diff_view = false,
      ---@type boolean | string[] -- true: auto-approve all tools, false: normal prompts, string[]: auto-approve specific tools by name
      auto_approve_tool_permissions = false, -- Default: show permission prompts for all tools
      auto_check_diagnostics = true,
      enable_fastapply = false,
    },
  },
  -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
  dependencies = {
    'stevearc/dressing.nvim',
    'nvim-lua/plenary.nvim',
    'MunifTanjim/nui.nvim',
    --- The below dependencies are optional,
    'hrsh7th/nvim-cmp', -- autocompletion for avante commands and mentions
    'nvim-tree/nvim-web-devicons', -- or echasnovski/mini.icons
    'zbirenbaum/copilot.lua', -- for providers='copilot'
    -- support for image pasting
    -- {
    --   -- support for image pasting
    --   'HakonHarnes/img-clip.nvim',
    --   event = 'VeryLazy',
    --   opts = {
    --     -- recommended settings
    --     default = {
    --       embed_image_as_base64 = false,
    --       prompt_for_file_name = false,
    --       drag_and_drop = {
    --         insert_mode = true,
    --       },
    --       -- required for Windows users
    --       use_absolute_path = true,
    --     },
    --   },
    -- },

    {
      -- Make sure to set this up properly if you have lazy=true
      'MeanderingProgrammer/render-markdown.nvim',
      opts = {
        file_types = { 'markdown', 'Avante' },
      },
      ft = { 'markdown', 'Avante' },
    },
  },
}
