vim.pack.add({
  "https://github.com/sindrets/diffview.nvim",
  "https://github.com/NeogitOrg/neogit",
})

require("diffview").setup({})
require("neogit").setup({})

vim.keymap.set("n", "<leader>gg", function()
  vim.cmd("Neogit")
end, { desc = "Show Neogit UI" })
