local function ensure_cache()
    if not vim.g.base46_cache or vim.g.base46_cache == '' then
        vim.g.base46_cache = vim.fn.stdpath 'data' .. '/base46_cache/'
    end

    -- 确保目录存在
    vim.fn.mkdir(vim.g.base46_cache, 'p')
end

local function ensure_compiled()
    ensure_cache()

    local required_files = {'defaults', 'syntax', 'treesitter'}
    local missing = false

    for _, file in ipairs(required_files) do
        if not vim.uv.fs_stat(vim.g.base46_cache .. file) then
            missing = true
            break
        end
    end

    if missing then
        -- 如果未编译或文件缺失，重新编译
        pcall(function()
            require('base46').compile()
        end)
    end
end

-- 必须在插件加载前设置缓存路径
ensure_cache()

return {{
    'NvChad/base46',
    lazy = false,
    priority = 1000,
    build = function()
        ensure_cache()
        require('base46').compile()
    end,
    config = function()
        ensure_compiled()
        -- 加载编译后的高亮组
        dofile(vim.g.base46_cache .. 'defaults')
        dofile(vim.g.base46_cache .. 'syntax')
        dofile(vim.g.base46_cache .. 'treesitter')
    end
}, {
    'NvChad/ui',
    lazy = false,
    config = function()
        require 'nvchad'
    end
}}
