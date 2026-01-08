-- nvim-navic 插件
--
-- 功能：在编辑器顶部显示当前代码的位置导航路径，类似 MyClass > MyFunc
--
-- 使用场景：
-- 1. 在大型代码文件中快速定位当前位置
-- 2. 查看当前光标所在的代码层级结构（如：文件 > 类 > 方法）
-- 3. 快速了解代码的层次结构
--
-- 工作方式：
-- 1. 依赖 LSP 服务来获取代码符号信息
-- 2. 自动在文件编辑时显示导航路径
-- 3. 实时更新当前位置信息
--
-- 注意事项：
-- 1. 需要正确配置 LSP 服务器才能工作
-- 2. 不同语言的显示效果可能略有差异
-- 3. 需要 LSP 服务器支持 documentSymbol 功能
--
-- 默认配置：
-- - 使用 '>' 作为分隔符显示层级
-- - 使用图标展示不同类型的代码元素
-- - 自动附加到所有支持的 LSP 服务器
--
-- 快捷键：默认不设置快捷键，自动显示在状态栏或 winbar 中
--
return {
  'SmiteshP/nvim-navic',
  lazy = true, -- Delay load until LSP attaches
  event = 'LspAttach', -- Load when LSP attaches to a buffer
  dependencies = {
    'neovim/nvim-lspconfig', -- 依赖 LSP 配置
  },
  config = function()
    local ok, navic = pcall(require, 'nvim-navic')
    if not ok then
      return
    end

    -- 基本配置
    navic.setup {
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
        if client and client.supports_method and client.supports_method('textDocument/documentSymbol') then
          navic.attach(client, buffer)
        end
      end,
    })
  end,
}
