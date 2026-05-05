vim.pack.add({
  { src = "https://github.com/akinsho/toggleterm.nvim", name = "toggleterm" },
})

require("toggleterm").setup({
  direction = "vertical",
  size = function()
    return vim.o.columns * 0.4
  end,
  persist_size = false,
})

vim.keymap.set("n", "<leader>vt", ":ToggleTerm<CR>", { desc = "Toggle Terminal" })
