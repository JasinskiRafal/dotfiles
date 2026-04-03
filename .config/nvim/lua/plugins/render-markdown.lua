-- return {
--   "MeanderingProgrammer/render-markdown.nvim",
--   event = "VeryLazy",
--   dependencies = {
--     "nvim-treesitter/nvim-treesitter",
--     "echasnovski/mini.nvim",
--   },
--   opts = {},
-- }

vim.pack.add({
  "https://github.com/MeanderingProgrammer/render-markdown.nvim",
})

require("render-markdown").setup({})
