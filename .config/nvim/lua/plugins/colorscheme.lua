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
}
