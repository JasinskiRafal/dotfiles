vim.pack.add({
  { src = "https://github.com/akinsho/toggleterm.nvim", name = "toggleterm" },
})

require("toggleterm").setup({
  direction = "vertical",
  size = vim.o.columns * 0.4,
})

vim.keymap.set("n", "<leader>vt", ":ToggleTerm<CR>", { desc = "Toggle Terminal" })
