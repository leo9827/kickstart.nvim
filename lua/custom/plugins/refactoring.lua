return {
  'ThePrimeagen/refactoring.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim', -- 用于异步操作
    'nvim-treesitter/nvim-treesitter', -- 用于代码语法解析
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
  end,
}
