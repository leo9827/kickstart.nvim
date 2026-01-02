-- Auto Session - Automatic session management
return {
  'rmagatti/auto-session',
  lazy = false,
  ---@module "auto-session"
  ---@type AutoSession.Config
  opts = {
    -- Suppress session management for certain directories
    suppressed_dirs = { '~/', '~/Downloads', '~/Documents', '~/Desktop', '/tmp' },

    -- Don't auto-restore the last session on startup
    auto_restore = false,

    -- Auto-save session on exit
    auto_save = true,

    -- Auto-create new sessions
    auto_create = true,

    -- Log level
    log_level = 'error',

    -- Use git branch name in session name
    use_git_branch = false,

    -- Session lens configuration for Telescope integration
    session_lens = {
      -- Load session on selection
      load_on_setup = true,

      -- Telescope theme
      theme_conf = {
        border = true,
      },

      previewer = 'summary',
    },
  },

  keys = {
    { '<leader>ws', '<cmd>AutoSession search<CR>', desc = '[W]orkspace [S]ession search' }, -- Search and select sessions
    { '<leader>wr', '<cmd>AutoSession restore<CR>', desc = '[W]orkspace Session [R]estore' }, -- Restore session for current directory
    { '<leader>ww', '<cmd>AutoSession save<CR>', desc = '[W]orkspace Session [W]rite (save)' }, -- Save current session
    { '<leader>wd', '<cmd>AutoSession delete<CR>', desc = '[W]orkspace Session [D]elete' }, -- Delete current session
  },
}
