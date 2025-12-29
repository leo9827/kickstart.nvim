-- NvChad UI 配置文件
-- 提供基础的 UI 组件支持

local M = {}

-- 默认配置
M.ui = {
  theme = 'flexoki',
  transparency = true,
  
  statusline = {
    enabled = false, -- 使用 lualine
  },
  
  tabufline = {
    enabled = false, -- 使用 bufferline
  },
}

return M
