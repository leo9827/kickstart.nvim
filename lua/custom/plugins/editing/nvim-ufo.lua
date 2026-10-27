-- Treesitter folds with indentation fallback; start with all folds open.
return {
  'kevinhwang91/nvim-ufo',
  event = { 'BufReadPost', 'BufNewFile' },
  dependencies = {
    'kevinhwang91/promise-async',
  },
  config = function()
    vim.o.foldcolumn = '1'
    vim.o.foldlevel = 99
    vim.o.foldlevelstart = 99
    vim.o.foldenable = true

    require('ufo').setup {
      provider_selector = function(bufnr, filetype)
        if filetype == 'neo-tree' or require('custom.large_file').is_large(bufnr) then
          return ''
        end
        return { 'treesitter', 'indent' }
      end,
      preview = {
        win_config = {
          border = 'rounded',
          winblend = 0,
          winhighlight = 'Normal:Normal',
        },
        mappings = {
          scrollU = '<C-u>',
          scrollD = '<C-d>',
          jumpTop = '[',
          jumpBot = ']',
        },
      },
      enable_get_fold_virt_text = true,
      -- Reserve room for the hidden-line count before truncating fold text.
      fold_virt_text_handler = function(virtual_text, start_line, end_line, width, truncate)
        local chunks = {}
        local suffix = (' 󰁂 %d '):format(end_line - start_line)
        local suffix_width = vim.fn.strdisplaywidth(suffix)
        local target_width = width - suffix_width
        local used_width = 0
        for _, chunk in ipairs(virtual_text) do
          local text = chunk[1]
          local chunk_width = vim.fn.strdisplaywidth(text)
          if target_width > used_width + chunk_width then
            used_width = used_width + chunk_width
            table.insert(chunks, chunk)
          else
            text = truncate(text, target_width - used_width)
            local highlight = chunk[2]
            table.insert(chunks, { text, highlight })
            chunk_width = vim.fn.strdisplaywidth(text)
            if used_width + chunk_width < target_width then
              suffix = suffix .. (' '):rep(target_width - used_width - chunk_width)
            end
            break
          end
        end
        table.insert(chunks, { suffix, 'MoreMsg' })
        return chunks
      end,
    }

    vim.keymap.set('n', 'zR', require('ufo').openAllFolds, { desc = 'Open all folds' })
    vim.keymap.set('n', 'zM', require('ufo').closeAllFolds, { desc = 'Close all folds' })
    vim.keymap.set('n', 'zr', require('ufo').openFoldsExceptKinds, { desc = 'Open folds except specified kinds' })
    vim.keymap.set('n', 'zm', require('ufo').closeFoldsWith, { desc = 'Close folds of specified kinds' })
  end,
}
