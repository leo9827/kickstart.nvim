return {
    "nvim-tree/nvim-tree.lua",
    version = "*",
    lazy = false,
    dependencies = {
        "nvim-tree/nvim-web-devicons",
    },
    config = function()
        -- 禁用 netrw
        vim.g.loaded_netrw = 1
        vim.g.loaded_netrwPlugin = 1

        require("nvim-tree").setup({
            -- 基础设置
            sort_by = "case_sensitive", -- 排序方式
            -- 视图设置
            view = {
                width = 30, -- 侧边栏宽度
                side = "right", -- 显示在左侧
                number = false, -- 显示行号
                relativenumber = false, -- 显示相对行号
                signcolumn = "yes", -- 显示图标列
            },
            -- 渲染设置
            renderer = {
                group_empty = true, -- 空文件夹分组
                indent_markers = {
                    enable = true, -- 启用缩进标记
                },
                icons = {
                    show = {
                        file = true,
                        folder = true,
                        folder_arrow = true,
                        git = true,
                    },
                },
            },
            -- 过滤器设置
            filters = {
                dotfiles = true, -- 隐藏点文件
                custom = {}, -- 自定义过滤规则
            },
            
            -- Git 集成
            git = {
                enable = true, -- 启用 Git 集成
                ignore = true, -- 忽略 .gitignore 文件
                timeout = 500, -- Git 状态刷新超时时间
            },
            
            -- 文件操作设置
            actions = {
                open_file = {
                    quit_on_open = false, -- 打开文件时不关闭树
                    resize_window = true, -- 调整窗口大小
                },
            },
            
            -- 系统设置
            system_open = {
                cmd = nil, -- 系统打开命令
                args = {}, -- 命令参数
            },
            actions = {
                open_file = {
                    quit_on_open = false,
                },
            },
        })

        -- 设置快捷键
        vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>', { silent = true })
        vim.keymap.set('n', '<leader>fe', ':NvimTreeFocus<CR>', { silent = true })
        -- 常用快捷键
        -- a       -- 创建文件/文件夹
        -- d       -- 删除
        -- r       -- 重命名
        -- x       -- 剪切
        -- c       -- 复制
        -- p       -- 粘贴
        -- R       -- 刷新
        -- -       -- 进入上级目录
        -- <CR>    -- 打开文件/展开文件夹

    -- -- 自动打开 nvim-tree（如果需要的话）-- 需添加到 init.lua 中
    -- vim.api.nvim_create_autocmd("VimEnter", {
    --     callback = function()
    --         require("nvim-tree.api").tree.open()
    --     end
    -- })

    -- -- 自动关闭
    -- vim.api.nvim_create_autocmd("BufEnter", {
    --     nested = true,
    --     callback = function()
    --         if #vim.api.nvim_list_wins() == 1 and require("nvim-tree.utils").is_nvim_tree_buf() then
    --             vim.cmd "quit"
    --         end
    --     end
    -- })

    end,
}
