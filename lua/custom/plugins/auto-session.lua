-- Auto Session - Automatic session management
return {
  'rmagatti/auto-session',
  lazy = false,
  ---@module "auto-session"
  ---@type AutoSession.Config
  opts = {
    -- Suppress session management for certain directories
    suppressed_dirs = {
      '~/',
      '~/Downloads',
      '~/Documents',
      '~/Desktop',
      '/tmp',
    },
    
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
      
      previewer = false,
    },
  },
  
  keys = {
    -- Search and select sessions
    {
      '<leader>qs',
      '<cmd>SessionSearch<CR>',
      desc = '[Q]uick [S]ession search',
    },
    
    -- Restore session for current directory
    {
      '<leader>qr',
      '<cmd>SessionRestore<CR>',
      desc = '[Q]uick Session [R]estore',
    },
    
    -- Save current session
    {
      '<leader>qw',
      '<cmd>SessionSave<CR>',
      desc = '[Q]uick Session [W]rite (save)',
    },
    
    -- Delete current session
    {
      '<leader>qd',
      '<cmd>SessionDelete<CR>',
      desc = '[Q]uick Session [D]elete',
    },
  },
}
