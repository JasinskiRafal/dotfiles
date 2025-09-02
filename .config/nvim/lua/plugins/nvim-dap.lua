return {
  {
    "mfussenegger/nvim-dap",
    keys = {
      {
        "<leader>db",
        function()
          require("dap").toggle_breakpoint()
        end,
        desc = "Breakpoint toggle",
        mode = { "n" },
      },
      {
        "<leader>dh",
        function()
          require("dap.ui.widgets").hover()
        end,
        desc = "Hover",
        mode = { "n", "v" },
      },
      {
        "<leader>dp",
        function()
          require("dap.ui.widgets").preview()
        end,
        desc = "Preview",
        mode = { "n", "v" },
      },
      {
        "<leader>dH",
        function()
          local widgets = require("dap.ui.widgets")
          widgets.centered_float(widgets.frames)
        end,
        desc = "frames centered",
        mode = { "n" },
      },
      {
        "<leader>ds",
        function()
          local widgets = require("dap.ui.widgets")
          widgets.centered_float(widgets.scopes)
        end,
        desc = "Scopes centered",
        mode = { "n" },
      },
      {
        "<leader>dc",
        function()
          require("dap").continue()
        end,
        desc = "Continue/Run",
        mode = { "n" },
      },
      {
        "<leader>da",
        function()
          require("dap").toggle_breakpoint()
          require("dap").continue()
          require("dap").toggle_breakpoint()
        end,
        desc = "Advance to cursor",
        mode = { "n" },
      },
      {
        "<leader>dd",
        function()
          require("dap").pause()
        end,
        desc = "Pause",
        mode = { "n" },
      },
      {
        "<leader>dC",
        function()
          require("dap").run_last()
        end,
        desc = "Run last",
        mode = { "n" },
      },
      {
        "<leader>ds",
        function()
          require("dap").step_over()
        end,
        desc = "Step over",
        mode = { "n" },
      },
      {
        "<leader>di",
        function()
          require("dap").step_into()
        end,
        desc = "Step into",
        mode = { "n" },
      },
      {
        "<leader>do",
        function()
          require("dap").step_out()
        end,
        desc = "Step out",
        mode = { "n" },
      },
      {
        "<leader>dt",
        function()
          require("dap").terminate()
        end,
        desc = "Terminate",
        mode = { "n" },
      },
    },
  },
  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
    lazy = false,
    keys = {
      {
        "<leader>de",
        function()
          require("dapui").close()

          if next(Snacks.picker.get({ source = "explorer" })) == nil then
            Snacks.explorer()
          end
        end,
        desc = "Exit debug ui",
        mode = { "n" },
      },
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      dapui.setup({
        icons = { expanded = "▾", collapsed = "▸", current_frame = "󰳟" },
        controls = {
          icons = {
            pause = "",
            play = "",
            step_into = "󰆹",
            step_over = "",
            step_out = "󰆸",
            terminate = "",
            disconnect = "",
          },
        },
      })

      dap.listeners.before.attach.dapui_config = function()
        dapui.open()
      end

      dap.listeners.before.launch.dapui_config = function()
        dapui.open()
      end

      dap.listeners.after.launch.dapui_config = function()
        if next(Snacks.picker.get({ source = "explorer" })) ~= nil then
          Snacks.explorer()
        end
      end

      vim.fn.sign_define("DapBreakpoint", { text = "🛑", texthl = "DiagnosticSignError", linehl = "", numhl = "" })
    end,
  },
  {
    "jay-babu/mason-nvim-dap.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "mfussenegger/nvim-dap",
    },
    opts = {
      handlers = {
        function(config)
          require("mason-nvim-dap").default_setup(config)
        end,
      },
    },
  },
  {
    "jedrzejboczar/nvim-dap-cortex-debug",
    opts = {},
  },
}
