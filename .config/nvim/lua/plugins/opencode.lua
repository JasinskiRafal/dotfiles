vim.pack.add({
  "https://github.com/nickjvandyke/opencode.nvim.git",
})

local opencode_cmd = "opencode --port"
local snacks_terminal_opts = {
  win = {
    position = "right",
    enter = false,
    on_win = function(win)
      -- Set up keymaps and cleanup for an arbitrary terminal
      require("opencode.terminal").setup(win.win)
    end,
  },
}
vim.g.opencode_opts = {
  server = {
    start = function()
      require("snacks.terminal").open(opencode_cmd, snacks_terminal_opts)
    end,
    stop = function()
      require("snacks.terminal").get(opencode_cmd, snacks_terminal_opts):close()
    end,
    toggle = function()
      require("snacks.terminal").toggle(opencode_cmd, snacks_terminal_opts)
    end,
  },
}

vim.api.nvim_create_user_command("Opencode", function()
  require("opencode").toggle()
end, { desc = "Toggle opencode terminal" })

vim.api.nvim_create_user_command("OpencodeStop", function()
  require("opencode").stop()
end, { desc = "Close opencode terminal" })
