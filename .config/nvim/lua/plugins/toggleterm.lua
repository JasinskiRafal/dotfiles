vim.pack.add({
  { src = "https://github.com/akinsho/toggleterm.nvim", name = "toggleterm" },
})

require("toggleterm").setup({
  direction = "float",
  float_opts = {
    border = "curved",
  },
})

vim.keymap.set("n", "<leader>vt", ":ToggleTerm<CR>", { desc = "Toggle Terminal" })
