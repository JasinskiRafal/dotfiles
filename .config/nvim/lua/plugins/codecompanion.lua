return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
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
