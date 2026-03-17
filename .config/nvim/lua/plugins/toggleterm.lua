return {
  "akinsho/toggleterm.nvim",
  opts = {
    direction = "float",
    float_opts = {
      border = "curved",
    },
  },
  keys = {
    {
      "<leader>vt",
      ":ToggleTerm<CR>",
      desc = "Toggle terminal",
    },
  },
}
