-- NvChad base46 theme system configuration
-- This file sets up base46 (theme engine) and NvChad UI components
return { -- Base46 theme engine - must load first
{
    'NvChad/base46',
    lazy = false,
    priority = 1000,
    config = function()
        -- Load and set global NvChad configuration
        -- nvconfig comes from NvChad/ui plugin and loads lua/chadrc.lua
        local config = require 'nvconfig'
        vim.g.nvconfig = config
        vim.g.base46_cache = vim.fn.stdpath 'data' .. '/base46_cache/'

        -- Compile and load theme
        local base46 = require 'base46'
        base46.load_all_highlights()
    end
}, -- NvChad UI components (optional, provides statusline, tabufline, etc.)
{
    'NvChad/ui',
    lazy = false,
    config = function()
        require 'nvchad'
    end
}}
