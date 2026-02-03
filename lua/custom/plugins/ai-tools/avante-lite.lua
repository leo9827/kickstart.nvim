return {
  dir = vim.fn.stdpath("config") .. "/local/avante-lite.nvim",
  name = "avante-lite.nvim",
  event = "VeryLazy",
  config = function()
    require("avante_lite").setup({
      openai = {
        -- model = "gpt-4o-mini",
      },
      ui = {
        -- position = "right",
        -- width = 50,
      },
    })
  end,
}

