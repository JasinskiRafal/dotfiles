-- this is a formatting plugin based on installed formatters
return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
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
}
