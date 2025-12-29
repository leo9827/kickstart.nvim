return {
    'stevearc/dressing.nvim',
    config = function()
        require('dressing').setup {
            input = {
                relative = 'cursor',
                anchor = 'NW',
                border = 'rounded',
                winblend = 5,
                max_width = 80
            },
            select = {
                enabled = true,
                backend = {'telescope', 'builtin'},
                builtin = {
                    relative = 'cursor',
                    anchor = 'NW',
                    border = 'rounded',
                    winblend = 5
                },
                telescope = require('telescope.themes').get_cursor {
                    layout_config = {
                        width = 0.45,
                        height = 0.4
                    },
                    prompt_title = false
                }
            }
        }
    end
}
