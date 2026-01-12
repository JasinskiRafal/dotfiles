return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    lazy = false,
    opts = {
      auto_install = true,
      highlight = { enable = true },
      indent = { enable = true },
      ensure_installed = {
        "c",
        "cpp",
        "lua",
        "json",
        "dockerfile",
        "python",
        "rust",
      },
      sync_install = true,
    },
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    opts = {},
  },
}
