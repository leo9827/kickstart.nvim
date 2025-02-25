-- GitHub Copilot 配置
return {
  -- 插件名称和来源
  'zbirenbaum/copilot.lua',

  -- 插件命令和触发条件
  cmd = 'Copilot',
  build = ':Copilot auth', -- 首次安装后需要运行此命令进行身份验证
  event = 'InsertEnter', -- 在进入插入模式时加载插件

  -- 插件配置
  config = function()
    require('copilot').setup {
      -- 主要配置
      suggestion = {
        enabled = false, -- 禁用内置建议功能
        -- auto_trigger = true,  -- 取消注释启用自动触发
        -- keymap = {
        --   accept = "<Tab>",   -- 使用 Tab 接受建议
        --   next = "<M-]>",     -- Alt+] 下一个建议
        --   prev = "<M-[>",     -- Alt+[ 上一个建议
        --   dismiss = "<C-]>",  -- Ctrl+] 关闭建议
        -- },
      },
      panel = {
        enabled = false, -- 禁用建议面板
      },
      filetypes = {
        -- 可以指定文件类型的行为
        -- ["*"] = true,       -- 对所有文件类型启用
        -- lua = true,
        -- python = true,
        -- javascript = true,
      },
      copilot_node_command = 'node', -- 指定 Node.js 路径
      server_opts_overrides = {}, -- 覆盖服务器选项
    }
  end,

  -- 可选: Copilot 与 nvim-cmp 集成
  -- 取消注释以下部分启用与 cmp 的集成
  -- dependencies = {
  --   {
  --     'zbirenbaum/copilot-cmp',
  --     config = function()
  --       require('copilot_cmp').setup({
  --         -- copilot-cmp 特定配置
  --         event = { "InsertEnter", "LspAttach" },
  --         fix_pairs = true,
  --       })
  --     end,
  --   }
  -- },
}
