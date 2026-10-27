return {
  'nvim-lualine/lualine.nvim',
  event = 'VeryLazy',
  opts = function()
    return {
      options = {
        theme = require('custom.theme').lualine_theme(),
        section_separators = '',
        component_separators = '',
        globalstatus = true, -- 是否在所有窗口显示状态栏
        disabled_filetypes = { statusline = { 'dashboard', 'alpha' } }, -- 在哪些文件类型中禁用状态栏
      },
      extensions = { 'neo-tree', 'lazy' }, -- 扩展，支持 neo-tree 和 lazy 插件
      sections = {
        lualine_a = {
          { 'mode', padding = 1 },
        },
        lualine_b = {
          { 'branch', icon = '' }, -- 显示 Git 分支
          { 'diff', icons_enabled = true }, -- 显示 Git 差异
        },
        lualine_c = {
          { 'filename', file_status = true, path = 1 }, -- 显示文件名和路径
          { 'diagnostics', sources = { 'nvim_diagnostic' } }, -- 显示诊断信息
          {
            -- 定义一个函数获取和展示录制状态
            function()
              local reg = vim.fn.reg_recording()
              if reg == '' then
                return ''
              end -- 如果没在录制，返回空
              return '  @' .. reg -- 显示图标和寄存器名
            end,
            color = 'DiagnosticWarn',
          },
        },
        lualine_x = {
          { 'filetype', icon_only = true, separator = '', padding = { left = 1, right = 0 } }, -- 显示文件类型图标
          { 'encoding' }, -- 显示文件编码
          { 'fileformat' }, -- 显示文件格式
        },
        lualine_y = {
          {
            'searchcount',
            maxcount = 999,
            timeout = 20,
            cond = function()
              return not vim.b.large_file
            end,
          },
          { 'progress', padding = 1 },
          { 'location', padding = 1 },
        },
        lualine_z = {
          { 'datetime', style = '%H:%M', padding = 1 },
        },
      },
    }
  end,
}
