return {
  'yetone/avante.nvim',
  event = 'VeryLazy',
  version = false, -- Never set it to '*', Never!
  build = 'make', -- build from source
  ---@module 'avante'
  ---@type avante.Config
  opts = {
    provider = 'copilot',
    -- auto_suggestions_provider = 'copilot',
    providers = {
      copilot = {
        endpoint = 'https://api.githubcopilot.com',
        -- 0x    GPT-5 mini
        -- 0.33x GPT-5.1-Codex-Mini | Claude Haiku 4.5 | Gemini-3 Flash
        model = 'claude-haiku-4.5',
        proxy = nil, -- [protocol://]host[:port] Use this proxy
        allow_insecure = false, -- Allow insecure server connections
        timeout = 30000, -- Timeout in milliseconds
        context_window = 64000, -- Number of tokens to send to the model for context
        extra_request_body = {
          temperature = 0.8, -- 越大越发散越随机
          max_tokens = 20480,
        },
      },
    },
    behaviour = {
      auto_focus_sidebar = true,
      auto_suggestions = false, -- Experimental stage
      auto_suggestions_respect_ignore = false,
      auto_set_highlight_group = true,
      auto_set_keymaps = true,
      auto_apply_diff_after_generation = false,
      jump_result_buffer_on_finish = true,
      support_paste_from_clipboard = false,
      minimize_diff = true,
      enable_token_counting = true,
      use_cwd_as_project_root = true,
      auto_focus_on_diff_view = true,
      ---@type boolean | string[] -- true: auto-approve all tools, false: normal prompts, string[]: auto-approve specific tools by name
      auto_approve_tool_permissions = false, -- Default: show permission prompts for all tools
      auto_check_diagnostics = true,
      enable_fastapply = false,
    },
    windows = {
      --- "right" | "left" | "top" | "bottom" | "smart"
      position = 'left',
    },
    diff = {
      autojump = true,
    },
  },
  -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
  dependencies = {
    'stevearc/dressing.nvim',
    'nvim-lua/plenary.nvim',
    'MunifTanjim/nui.nvim',
    --- The below dependencies are optional,
    -- 'hrsh7th/nvim-cmp', -- autocompletion for avante commands and mentions
    -- 'nvim-tree/nvim-web-devicons', -- or echasnovski/mini.icons
    'zbirenbaum/copilot.lua', -- for providers='copilot'
    -- {
    --   -- Make sure to set this up properly if you have lazy=true
    --   'MeanderingProgrammer/render-markdown.nvim',
    --   opts = {
    --     file_types = { 'markdown', 'Avante' },
    --   },
    --   ft = { 'markdown', 'Avante' },
    -- },
  },
}
