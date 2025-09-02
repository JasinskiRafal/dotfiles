return {
  { "mason-org/mason.nvim", opts = {} },
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = {
      "mason-org/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    opts = {
      automatic_enable = false,
    },
  },
  {
    "WhoIsSethDaniel/mason-tool-installer",
    dependencies = {
      "mason-org/mason.nvim",
      config = true,
    },
    opts = {
      ensure_installed = {
        "autopep8",
        "clangd",
        "clang-format",
        "cortex-debug",
        "cpptools",
        "debugpy",
        "lua-language-server",
        "pyrefly",
        "rust-analyzer",
        "stylua",
        "tombi",
      },
    },
  },
}
