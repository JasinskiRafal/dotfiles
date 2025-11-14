return {
  {
    "sainnhe/gruvbox-material",
    priority = 1000,
    opts = {},
    init = function()
      vim.g.gruvbox_material_background = "hard"
      vim.g.gruvbox_material_float_style = "blend"
      vim.g.gruvbox_material_diagnostic_virtual_text = "colored"
      vim.cmd.colorscheme("gruvbox-material")
    end,
  },
  {
    "marko-cerovac/material.nvim",
    priority = 1000,
    opts = {},
    -- init = function()
    --   vim.g.material_style = "deep ocean"
    --   vim.cmd.colorscheme("material")
    -- end,
  },
  {
    "Mofiqul/vscode.nvim",
    priority = 1000,
    opts = {
      style = "dark",
      italic_comments = true,
      underline_links = true,
      color_overrides = {
        vscCursorDarkDark = "#2d2d2d",
      },
    },
    -- init = function()
    --   vim.cmd.colorscheme("vscode")
    -- end,
  },
}
