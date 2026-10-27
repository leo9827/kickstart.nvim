return {

  { -- Linting
    'mfussenegger/nvim-lint',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      local lint = require 'lint'

      -- 为常用文件类型声明 linter，这里按需添加即可（不会强制安装依赖）
      lint.linters_by_ft = {
        sql = { 'sqlfluff' },
      }

      -- 只在对应的可执行文件存在时才触发，以免出现「命令不存在」的噪音
      local function get_available_linters()
        local linters = lint.linters_by_ft[vim.bo.filetype]
        if not linters then
          return nil
        end

        return vim.tbl_filter(function(linter)
          local linter_cfg = lint.linters[linter]
          local cmd = linter_cfg and linter_cfg.cmd or linter
          return cmd and vim.fn.executable(cmd) == 1
        end, linters)
      end

      -- Lint on read/save, not on every edit or buffer switch.
      local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })
      vim.api.nvim_create_autocmd({ 'BufReadPost', 'BufWritePost' }, {
        group = lint_augroup,
        callback = function()
          -- Skip read-only plugin windows and large files.
          if vim.bo.modifiable and not vim.b.large_file then
            local active_linters = get_available_linters()
            if active_linters and #active_linters > 0 then
              lint.try_lint(active_linters)
            end
          end
        end,
      })
    end,
  },
}
