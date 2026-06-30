vim.pack.add({
  "https://github.com/marc0x71/mesone.nvim",
})

require("mesone").setup({
  build_type = "debug",
  auto_compile = false,
  compile_before_run = true,
  dap_adapter = "cppdbg",
})
