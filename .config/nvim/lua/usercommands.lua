require("snacks")

vim.api.nvim_create_user_command("TermOpen", function()
  Snacks.terminal.open()
end, {})

vim.api.nvim_create_user_command("TermOpen", function()
  Snacks.terminal.toggle()
end, {})

vim.api.nvim_create_user_command("DebugExit", function()
  require("dapui").close()
  if next(Snacks.picker.get({ source = "explorer" })) == nil then
    Snacks.explorer()
  end
end, { desc = "Exit debug UI" })
