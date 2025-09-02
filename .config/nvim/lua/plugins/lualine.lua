return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = {
    options = {
      theme = "auto",
      globalstatus = true,
    },
    sections = {
      lualine_c = {
        {
          "filename",
          path = 1,
          symbols = {
            modified = "[Modified]",
            readonly = "[Read-only]",
          },
        },
      },
    },
  },
}
