return {
  {
    "akinsho/toggleterm.nvim",
    opts = { direction = "vertical" , size = vim.o.columns * 0.4},
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
  },
}
