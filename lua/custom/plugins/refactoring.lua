-- 代码重构插件，提供多种重构功能:
-- 1. 提取变量 - 将选中代码提取为变量
-- 2. 提取函数 - 将选中代码提取为函数
-- 3. 内联变量 - 将变量替换为其值
-- 4. 内联函数 - 将函数调用替换为函数体
-- 5. 提取到新文件 - 将选中代码移动到新文件
--
-- 使用方式:
-- 1. 选中要重构的代码(可视模式)
-- 2. 按 <leader>rr 打开重构菜单
-- 3. 选择要执行的重构操作
--
-- 常用快捷键:
-- <leader>re - 提取函数
-- <leader>rf - 提取到文件
-- <leader>rv - 提取变量
-- <leader>ri - 内联变量
--
-- 最常用场景:
-- 1. 提取重复代码为函数
-- 2. 将复杂逻辑拆分成小函数
-- 3. 提取魔法值为命名变量
-- 4. 重构大文件为多个小文件

return {
  'ThePrimeagen/refactoring.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim', -- 用于异步操作
    'nvim-treesitter/nvim-treesitter', -- 用于代码语法解析
    -- 'nvim-telescope/telescope.nvim',
  },
  lazy = false, -- 是否延迟加载
  config = function()
    require('refactoring').setup {
      prompt_func_return_type = {
        -- go = true, -- 在提取函数时提示返回类型
      },
      prompt_func_param_type = {
        -- go = true, -- 在提取函数时提示参数类型
      },
      printf_statements = {
        go = {
          -- 用于打印变量的语句
          'fmt.Printf("%s: %v\\n", "%s", %s)',
        },
      },
      print_var_statements = {
        go = {
          -- 用于打印变量的语句
          'fmt.Println(%s)',
        },
      },
    }

    -- --- 快捷键映射 ---

    -- 在可视化模式下选择代码块后，按下 <leader>r 触发重构菜单
    vim.keymap.set('v', '<leader>r', function()
      require('telescope').extensions.refactoring.refactors()
    end, { desc = 'Refactor: 打开重构菜单' })
  end,
}
