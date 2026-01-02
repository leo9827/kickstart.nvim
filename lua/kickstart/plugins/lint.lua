return {

  { -- Linting
    'mfussenegger/nvim-lint',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      local lint = require 'lint'

      -- 为常用文件类型声明 linter，这里按需添加即可（不会强制安装依赖）
      lint.linters_by_ft = {
        markdown = { 'markdownlint' },
        sql = { 'sqlfluff' }, -- Mason 已安装 sqlfluff，SQL 文件可直接使用
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

      -- To allow other plugins to add linters to require('lint').linters_by_ft,
      -- instead set linters_by_ft like this:
      -- lint.linters_by_ft = lint.linters_by_ft or {}
      -- lint.linters_by_ft['markdown'] = { 'markdownlint' }
      --
      -- However, note that this will enable a set of default linters,
      -- which will cause errors unless these tools are available:
      -- {
      --   clojure = { "clj-kondo" },
      --   dockerfile = { "hadolint" },
      --   inko = { "inko" },
      --   janet = { "janet" },
      --   json = { "jsonlint" },
      --   markdown = { "vale" },
      --   rst = { "vale" },
      --   ruby = { "ruby" },
      --   terraform = { "tflint" },
      --   text = { "vale" }
      -- }
      --
      -- You can disable the default linters by setting their filetypes to nil:
      -- lint.linters_by_ft['clojure'] = nil
      -- lint.linters_by_ft['dockerfile'] = nil
      -- lint.linters_by_ft['inko'] = nil
      -- lint.linters_by_ft['janet'] = nil
      -- lint.linters_by_ft['json'] = nil
      -- lint.linters_by_ft['markdown'] = nil
      -- lint.linters_by_ft['rst'] = nil
      -- lint.linters_by_ft['ruby'] = nil
      -- lint.linters_by_ft['terraform'] = nil
      -- lint.linters_by_ft['text'] = nil

      -- Create autocommand which carries out the actual linting
      -- on the specified events.
      local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })
      vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
        group = lint_augroup,
        callback = function()
          -- Only run the linter in buffers that you can modify in order to
          -- avoid superfluous noise, notably within the handy LSP pop-ups that
          -- describe the hovered symbol using Markdown.
          if vim.bo.modifiable then
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
