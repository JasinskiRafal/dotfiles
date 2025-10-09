return {
  "stevearc/conform.nvim",
  cmd = { "ConformInfo", "Format" },
  keys = {
    {
      "<leader>tf",
      function()
        require("conform").format({ timeout_ms = 500, lsp_format = "fallback" })
      end,
      desc = "Format current buffer",
    },
  },
  opts = {
    notify_on_error = true,
    formatters_by_ft = {
      lua = { "stylua" },
      cpp = { "clang-format" },
      c = { "clang-format" },
      rust = { "rustfmt" },
      python = { "autopep8" },
    },
  },
  config = function(_, opts)
    require("conform").setup(opts)

    vim.api.nvim_create_user_command("Format", function()
      require("conform").format({ timeout_ms = 500, lsp_format = "fallback" })
    end, { desc = "Format current buffer" })
  end,
}
