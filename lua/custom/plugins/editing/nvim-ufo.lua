-- nvim-ufo 代码折叠插件
-- 该插件提供更好的代码折叠体验，支持 treesitter 和缩进两种折叠方式
--
-- 使用场景：
-- 1. 查看大文件时，可以折叠不关注的代码块
-- 2. 在代码review时，可以按照层级折叠代码，更好地理解代码结构
-- 3. 编写代码时，可以折叠其他函数，专注于当前编辑的部分
--
-- 常用快捷键：
-- zR - 展开所有折叠
-- zM - 折叠所有代码
-- zr - 展开指定类型的折叠
-- zm - 折叠指定类型的代码
-- zo - 打开当前折叠
-- zc - 关闭当前折叠
-- za - 切换当前折叠状态
--
-- 折叠预览快捷键：
-- <C-u> - 预览窗口向上滚动
-- <C-d> - 预览窗口向下滚动
-- [ - 跳转到预览窗口顶部
-- ] - 跳转到预览窗口底部

return {
  -- 折叠代码插件
  'kevinhwang91/nvim-ufo',
  dependencies = {
    'kevinhwang91/promise-async', -- 异步支持
  },
  config = function(_, opts)
    -- 基础折叠设置
    vim.o.foldcolumn = '1' -- 显示折叠列，'0' 是不显示
    vim.o.foldlevel = 99 -- 默认打开所有折叠
    vim.o.foldlevelstart = 99 -- 打开文件时默认展开所有折叠
    vim.o.foldenable = true -- 启用折叠

    -- 配置 ufo
    require('ufo').setup {
      -- 折叠提供者
      provider_selector = function(bufnr, filetype, buftype)
        if filetype == 'python' then
          return { 'indent' }
        end
        return { 'treesitter', 'indent' } -- 优先使用 treesitter，其次使用缩进
      end,
      -- 折叠预览窗口
      preview = {
        win_config = {
          border = 'rounded', -- 预览窗口边框样式
          winblend = 0, -- 窗口透明度
          winhighlight = 'Normal:Normal', -- 高亮设置
        },
        mappings = {
          scrollU = '<C-u>', -- 向上滚动
          scrollD = '<C-d>', -- 向下滚动
          jumpTop = '[', -- 跳转到顶部
          jumpBot = ']', -- 跳转到底部
        },
      },
      -- 折叠动画
      enable_get_fold_virt_text = true, -- 启用虚拟文本
      fold_virt_text_handler = function(virtText, lnum, endLnum, width, truncate)
        local newVirtText = {}
        local suffix = (' 󰁂 %d '):format(endLnum - lnum)
        local sufWidth = vim.fn.strdisplaywidth(suffix)
        local targetWidth = width - sufWidth
        local curWidth = 0
        for _, chunk in ipairs(virtText) do
          local chunkText = chunk[1]
          local chunkWidth = vim.fn.strdisplaywidth(chunkText)
          if targetWidth > curWidth + chunkWidth then
            curWidth = curWidth + chunkWidth
            table.insert(newVirtText, chunk)
          else
            chunkText = truncate(chunkText, targetWidth - curWidth)
            local hlGroup = chunk[2]
            table.insert(newVirtText, { chunkText, hlGroup })
            chunkWidth = vim.fn.strdisplaywidth(chunkText)
            if curWidth + chunkWidth < targetWidth then
              suffix = suffix .. (' '):rep(targetWidth - curWidth - chunkWidth)
            end
            break
          end
        end
        table.insert(newVirtText, { suffix, 'MoreMsg' })
        return newVirtText
      end,
    }

    -- Keybindings
    vim.keymap.set('n', 'zR', require('ufo').openAllFolds, { desc = 'Open all folds' })
    vim.keymap.set('n', 'zM', require('ufo').closeAllFolds, { desc = 'Close all folds' })
    vim.keymap.set('n', 'zr', require('ufo').openFoldsExceptKinds, { desc = 'Open folds except specified kinds' })
    vim.keymap.set('n', 'zm', require('ufo').closeFoldsWith, { desc = 'Close folds of specified kinds' })
  end,
}
