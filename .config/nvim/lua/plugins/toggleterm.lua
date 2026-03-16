return {
  "akinsho/toggleterm.nvim",
  opts = { direction = "tab" },
  keys = {
    {
      "<leader>vt",
      ":ToggleTerm<CR>",
      desc = "Toggle terminal",
    },
    {
      "<leader>vT",
      ":TermNew<CR>",
      desc = "Open new terminal",
    },
  },
}
