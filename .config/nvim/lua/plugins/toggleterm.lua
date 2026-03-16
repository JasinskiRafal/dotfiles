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
    {
      "<Esc><Esc>",
      "<C-\\><C-n> :ToggleTerm<CR>",
      mode = "t",
      desc = "Exit terminal mode",
    },
  },
}
