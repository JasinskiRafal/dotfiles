-- helper function for mapping
local function map(button, command, options, mode)
  options = options or {}
  mode = mode or { "n" }

  vim.keymap.set(mode, button, command, options)
end

map("<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
map("<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
map("<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
map("<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

map("<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" }, "t")
