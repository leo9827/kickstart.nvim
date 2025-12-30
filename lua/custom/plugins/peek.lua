return {
  {
    'toppair/peek.nvim', -- Markdown预览插件
    event = { 'VeryLazy' }, -- 在VeryLazy事件时加载，延迟加载以提高启动速度
    build = 'deno task --quiet build:fast', -- 使用deno构建插件，quiet模式减少输出，fast模式快速构建
    config = function()
      require('peek').setup {
        filetype = { 'markdown', 'conf' }, -- 支持的文件类型：markdown和conf文件
      }
      -- 创建用户命令：PeekOpen，用于打开预览窗口
      vim.api.nvim_create_user_command('PeekOpen', require('peek').open, {})
      -- 创建用户命令：PeekClose，用于关闭预览窗口
      vim.api.nvim_create_user_command('PeekClose', require('peek').close, {})
    end,
  },
}
