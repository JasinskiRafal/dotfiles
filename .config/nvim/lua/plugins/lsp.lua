vim.pack.add({
  "https://github.com/neovim/nvim-lspconfig",
  "https://github.com/mason-org/mason-lspconfig.nvim",
})

require("mason-lspconfig").setup({})

vim.lsp.config("clangd", {
  cmd = {
    "clangd",
    "--query-driver=/usr/bin/aarch64-linux-gnu-*,/usr/bin/*g++*,/usr/bin/*gcc*,/usr/bin/*clang*",
  },
})

