-- nvim-navic 是一个显示当前代码位置的插件
-- 它会在状态栏或 winbar 中显示类似 "文件 > 类 > 函数" 这样的导航路径
-- 需要 LSP 支持才能工作
return {
  'SmiteshP/nvim-navic',
  dependencies = {
    'neovim/nvim-lspconfig', -- 依赖 LSP 配置
  },
  config = function()
    local navic = require 'nvim-navic'

    -- 基本配置
    navic.setup {
      -- 图标配置
      icons = {
        File = ' ', -- 文件图标
        Module = ' ', -- 模块图标
        Namespace = ' ', -- 命名空间图标
        Package = ' ', -- 包图标
        Class = ' ', -- 类图标
        Method = ' ', -- 方法图标
        Property = ' ', -- 属性图标
        Field = ' ', -- 字段图标
        Constructor = ' ', -- 构造函数图标
        Enum = ' ', -- 枚举图标
        Interface = ' ', -- 接口图标
        Function = ' ', -- 函数图标
        Variable = ' ', -- 变量图标
        Constant = ' ', -- 常量图标
        String = ' ', -- 字符串图标
        Number = ' ', -- 数字图标
        Boolean = ' ', -- 布尔值图标
        Array = ' ', -- 数组图标
        Object = ' ', -- 对象图标
        Key = ' ', -- 键图标
        Null = ' ', -- 空值图标
        EnumMember = ' ', -- 枚举成员图标
        Struct = ' ', -- 结构体图标
        Event = ' ', -- 事件图标
        Operator = ' ', -- 运算符图标
        TypeParameter = ' ', -- 类型参数图标
      },

      -- 导航路径配置
      separator = ' > ', -- 分隔符
      depth_limit = 0, -- 深度限制（0表示无限制）
      depth_limit_indicator = '..', -- 深度限制指示器
      safe_output = true, -- 安全输出模式
      click = false, -- 是否允许点击

      -- 高亮配置
      highlight = true, -- 启用高亮
      lsp = {
        auto_attach = true, -- 自动附加到 LSP
        preference = nil, -- LSP 服务器偏好
      },
    }

    -- 在 LSP 启动时自动附加 navic
    vim.api.nvim_create_autocmd('LspAttach', {
      callback = function(args)
        local buffer = args.buf
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        -- 确认 LSP 服务器支持文档符号功能
        if client.supports_method 'textDocument/documentSymbol' then
          navic.attach(client, buffer)
        end
      end,
    })
  end,
}
