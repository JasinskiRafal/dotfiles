vim.pack.add({
  "https://github.com/igorlfs/nvim-dap-view.git",
})

require("dap-view").setup({
  windows = {
    size = 0.4,
    position = "right",
  },
  winbar = {
    sections = {
      "watches",
      "scopes",
      "exceptions",
      "breakpoints",
      "threads",
      "repl",
      "rtt",
    },
  },
  auto_toggle = true,
})

-- UI
vim.keymap.set("n", "<leader>de", function()
  dapview.close()
end, { desc = "Exit debug ui" })
