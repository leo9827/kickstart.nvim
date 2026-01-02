-- nvim-surround 是一个用于快速添加、修改和删除包围符号的插件
-- 常见用例：
-- 1. 添加包围：按 ys + 动作 + 符号，例如 ysiw" 会给当前单词添加双引号
-- 2. 删除包围：按 ds + 符号，例如 ds" 会删除一对双引号
-- 3. 修改包围：按 cs + 旧符号 + 新符号，例如 cs"' 会把双引号改成单引号
-- 4. 在可视模式下：按 S + 符号可以给选中内容添加包围
return {
  'kylechui/nvim-surround',
  version = '^3.0.0', -- 使用稳定版本，如果需要最新特性可以删除此行使用 main 分支
  event = 'VeryLazy', -- 延迟加载：在编辑器准备好后再加载插件
  config = function()
    require('nvim-surround').setup {
      -- 插件配置项
      keymaps = {
        insert = '<C-g>s', -- 插入模式下的快捷键
        insert_line = '<C-g>S', -- 插入模式下在新行添加包围
        normal = 'ys', -- 普通模式下的快捷键
        normal_cur = 'yss', -- 普通模式下对当前行操作
        normal_line = 'yS', -- 普通模式下在新行添加包围
        normal_cur_line = 'ySS', -- 对当前行在新行添加包围
        visual = 'S', -- 可视模式下的快捷键
        visual_line = 'gS', -- 可视模式下在新行添加包围
        delete = 'ds', -- 删除包围的快捷键
        change = 'cs', -- 修改包围的快捷键
      },
      surrounds = {
        -- 可以在这里自定义新的包围规则
        -- 例如：HTML 标签、LaTeX 命令等
      },
      aliases = {
        -- 为符号定义别名
        ['a'] = false, -- 禁用某个别名
        ['b'] = ')', -- 把 b 映射为 )
        ['B'] = '}', -- 把 B 映射为 }
        ['r'] = ']', -- 把 r 映射为 ]
        ['q'] = { '"', "'", '`' }, -- 把 q 映射为引号
      },
    }
  end,
}
