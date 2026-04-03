vim.pack.add({
  "https://github.com/mason-org/mason.nvim",
  "https://github.com/WhoIsSethDaniel/mason-tool-installer",
})

require("mason").setup({})
require("mason-tool-installer").setup({
  ensure_installed = {
    "autopep8",
    "clangd",
    "clang-format",
    "codelldb",
    "cortex-debug",
    "debugpy",
    "lua-language-server",
    "pyrefly",
    "rust-analyzer",
    "stylua",
    "tombi",
  },
})
