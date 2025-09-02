return {
  "echasnovski/mini.nvim",
  version = "*",
  config = function()
    -- text editing
    require("mini.ai").setup()
    require("mini.comment").setup()
    require("mini.pairs").setup({ mappings = { ["'"] = false } })
    require("mini.surround").setup()
    -- general workflow
    require("mini.bracketed").setup()
    -- appearance
    require("mini.icons").setup()
    require("mini.icons").mock_nvim_web_devicons()
    require("mini.trailspace").setup()
  end,
  lazy = false,
  keys = {
    -- Top Pickers & Explorer
    {
      "<leader>tr",
      function()
        MiniTrailspace.trim()
      end,
      desc = "Trim trailing whitespaces",
      mode = { "n" },
    },
  },
}
