vim.pack.add({
  "https://github.com/echasnovski/mini.nvim",
})

-- text editing
require("mini.ai").setup()
require("mini.comment").setup()
require("mini.pairs").setup({ mappings = { ["'"] = false } })
require("mini.surround").setup()

require("mini.trailspace").setup()
vim.keymap.set("n", "<leader>tr", function()
  MiniTrailspace.trim()
end, { desc = "Trim trailing whitespaces" })

-- general workflow
require("mini.bracketed").setup()

-- appearance
require("mini.icons").setup()
require("mini.icons").mock_nvim_web_devicons()
require("mini.diff").setup({
  view = {
    style = "sign",
    signs = {
      add = "|",
      change = "|",
      delete = "|",
    },
  },
})

local enable_trail_highlight = function(args)
  vim.b[args.buf].minitrailspace_disable = true
end
vim.api.nvim_create_autocmd("User", { pattern = "SnacksDashboardOpened", callback = enable_trail_highlight })
