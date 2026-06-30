vim.pack.add({
  "https://github.com/JasinskiRafal/nvim-dap-cortex-debug.git",
})

require("dap-cortex-debug").setup({
  dapui_rtt = false,
})
