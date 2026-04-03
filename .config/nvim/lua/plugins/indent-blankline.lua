vim.pack.add({
  "https://github.com/lukas-reineke/indent-blankline.nvim.git",
})

require("ibl").setup({
  indent = {
    char = "╎",
  },
})
