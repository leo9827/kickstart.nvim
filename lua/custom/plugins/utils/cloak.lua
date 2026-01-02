return {
  'laytan/cloak.nvim', -- 敏感信息隐藏插件
  config = function()
    require('cloak').setup {
      enabled = true, -- 启用插件
      cloak_character = '*', -- 用于隐藏敏感信息的字符，默认为星号
      -- 应用于隐藏内容的高亮组（颜色），参见 `:h highlight`。
      highlight_group = 'Comment',
      patterns = {
        {
          -- 匹配以 ".env" 开头的任何文件。
          -- 这可以是一个表来匹配多个文件模式。
          file_pattern = {
            '.env*', -- 环境变量文件
            'wrangler.toml', -- Cloudflare Workers配置文件
            '.dev.vars', -- 开发环境变量文件
          },
          -- 匹配等号及其后的任何字符。
          -- 这也可以是一个用于隐藏的模式表，
          -- 例如：cloak_pattern = { ":.+", "-.+" } 用于yaml文件。
          cloak_pattern = '=.+', -- 隐藏等号后的所有内容（即变量值）
        },
      },
    }
  end,
}
