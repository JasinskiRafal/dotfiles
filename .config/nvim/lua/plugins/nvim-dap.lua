vim.pack.add({
  "https://github.com/mfussenegger/nvim-dap",
  "https://github.com/nvim-neotest/nvim-nio",
  "https://github.com/jay-babu/mason-nvim-dap.nvim",
  "https://github.com/JasinskiRafal/nvim-dap-cortex-debug.git",
  "https://github.com/igorlfs/nvim-dap-view.git",
})

require("dap-view").setup({
  windows = {
    size = 0.4,
    position = "right",
  },
  winbar = {
    sections = {
      "watches",
      "scopes",
      "exceptions",
      "breakpoints",
      "threads",
      "repl",
      "rtt",
    },
  },
  auto_toggle = true,
})
require("mason-nvim-dap").setup({
  handlers = {
    function(config)
      require("mason-nvim-dap").default_setup(config)
    end,
  },
})
require("dap-cortex-debug").setup({
  dapui_rtt = false,
})

-- Attach listeners
local dapview = require("dap-view")

vim.fn.sign_define("DapBreakpoint", { text = "🛑", texthl = "DiagnosticSignError", linehl = "", numhl = "" })

-- Inspection
vim.keymap.set({ "n" }, "<leader>db", function()
  require("dap").toggle_breakpoint()
end, { desc = "Breakpoint toggle" })
vim.keymap.set({ "n", "v" }, "<leader>dh", function()
  require("dap.ui.widgets").hover()
end, { desc = "Hover" })
vim.keymap.set({ "n", "v" }, "<leader>dp", function()
  require("dap.ui.widgets").preview()
end, { desc = "Preview" })
vim.keymap.set({ "n" }, "<leader>dH", function()
  local widgets = require("dap.ui.widgets")
  widgets.centered_float(widgets.frames)
end, { desc = "frames centered" })
vim.keymap.set({ "n" }, "<leader>ds", function()
  local widgets = require("dap.ui.widgets")
  widgets.centered_float(widgets.scopes)
end, { desc = "Scopes centered" })

-- Execution
vim.keymap.set({ "n" }, "<leader>dc", function()
  require("dap").continue()
end, { desc = "Continue/Run" })
vim.keymap.set({ "n" }, "<leader>da", function()
  require("dap").run_to_cursor()
end, { desc = "Advance to cursor" })
vim.keymap.set({ "n" }, "<leader>dd", function()
  require("dap").pause()
end, { desc = "Pause" })
vim.keymap.set({ "n" }, "<leader>dC", function()
  require("dap").run_last()
end, { desc = "Run last" })
vim.keymap.set({ "n" }, "<leader>ds", function()
  require("dap").step_over()
end, { desc = "Step over" })
vim.keymap.set({ "n" }, "<leader>di", function()
  require("dap").step_into()
end, { desc = "Step into" })
vim.keymap.set({ "n" }, "<leader>do", function()
  require("dap").step_out()
end, { desc = "Step out" })
vim.keymap.set({ "n" }, "<leader>dt", function()
  require("dap").terminate()
end, { desc = "Terminate" })

-- Execution Function keys
vim.keymap.set({ "n" }, "<F5>", function()
  require("dap").continue()
end, { desc = "Continue/Run" })
vim.keymap.set({ "n" }, "<F6>", function()
  require("dap").step_over()
end, { desc = "Step over" })
vim.keymap.set({ "n" }, "<F7>", function()
  require("dap").step_into()
end, { desc = "Step into" })
vim.keymap.set({ "n" }, "<F8>", function()
  require("dap").step_out()
end, { desc = "Step out" })
vim.keymap.set({ "n" }, "<F10>", function()
  require("dap").terminate()
end, { desc = "Terminate" })

-- UI
vim.keymap.set("n", "<leader>de", function()
  dapview.close()
end, { desc = "Exit debug ui" })
