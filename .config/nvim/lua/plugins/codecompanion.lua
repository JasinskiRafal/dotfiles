return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  keys = {
    {
      "<leader>CC",
      ":CodeCompanionChat<CR>",
      desc = "Open Code Companion Chat",
    },
  },
  opts = {
    strategies = {
      chat = {
        adapter = {
          name = "mistral",
          model = "mistral-large-latest",
        },
      },
      inline = {
        adapter = {
          name = "mistral",
          model = "mistral-large-latest",
        },
      },
      cmd = {
        adapter = {
          name = "mistral",
          model = "mistral-large-latest",
        },
      },
    },
    opts = {
      log_level = "DEBUG",
    },
  },
}
