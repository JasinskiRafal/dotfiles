vim.pack.add({
  "https://github.com/folke/snacks.nvim",
})

require("snacks").setup({
  bigfile = { enabled = true },
  bufdelete = { enabled = true },
  dashboard = {
    enabled = true,
    preset = {
      header = [[
 ░   ░░░  ░░        ░░░      ░░░  ░░░░  ░░        ░░  ░░░░  ░
 ▒    ▒▒  ▒▒  ▒▒▒▒▒▒▒▒  ▒▒▒▒  ▒▒  ▒▒▒▒  ▒▒▒▒▒  ▒▒▒▒▒   ▒▒   ▒
 ▓  ▓  ▓  ▓▓      ▓▓▓▓  ▓▓▓▓  ▓▓▓  ▓▓  ▓▓▓▓▓▓  ▓▓▓▓▓        ▓
 █  ██    ██  ████████  ████  ████    ███████  █████  █  █  █
 █  ███   ██        ███      ██████  █████        ██  ████  █
         ]],
    },
    sections = {
      {
        section = "terminal",
        cmd = { "rbonsai" },
        height = 30,
        padding = 4,
      },
      { section = "header" },
    },
  },
  explorer = {
    enabled = true,
  },
  indent = {
    enabled = true,
    only_scope = true,
    animate = { enabled = false },
  },
  git = { enabled = true },
  input = { enabled = true },
  notifier = { enabled = true, timeout = 5000 },
  picker = { enabled = true },
  quickfile = { enabled = true },
  rename = { enabled = true },
  scope = { enabled = true },
  statuscolumn = { enabled = true },
  words = { enabled = true },
})

-- Bufdelete
vim.keymap.set("n", "<leader>bd", function()
  Snacks.bufdelete.other()
end, { desc = "Delete other buffers" })
-- Top Pickers & Explorer
vim.keymap.set("n", "<leader><space>", function()
  Snacks.picker.smart()
end, { desc = "Smart Find Files" })
vim.keymap.set("n", "<leader>,", function()
  Snacks.picker.buffers({nofile=true})
end, { desc = "Buffers" })
vim.keymap.set("n", "<leader>/", function()
  Snacks.picker.grep()
end, { desc = "Grep" })
vim.keymap.set("n", "<leader>:", function()
  Snacks.picker.command_history()
end, { desc = "Command History" })
vim.keymap.set("n", "<leader>n", function()
  Snacks.picker.notifications()
end, { desc = "Notification History" })
vim.keymap.set("n", "<leader>e", function()
  Snacks.explorer()
end, { desc = "File Explorer" })

-- find
vim.keymap.set("n", "<leader>fb", function()
  Snacks.picker.buffers()
end, { desc = "Buffers" })
vim.keymap.set("n", "<leader>fc", function()
  Snacks.picker.files({ cwd = vim.fn.stdpath("config") })
end, { desc = "Find Config File" })
vim.keymap.set("n", "<leader>ff", function()
  Snacks.picker.files()
end, { desc = "Find Files" })
vim.keymap.set("n", "<leader>fF", function()
  Snacks.picker.files({ hidden = true, ignored = true })
end, { desc = "Find Files" })
vim.keymap.set("n", "<leader>fp", function()
  Snacks.picker.projects()
end, { desc = "Projects" })
vim.keymap.set("n", "<leader>fr", function()
  Snacks.picker.recent()
end, { desc = "Recent" })

-- Grep
vim.keymap.set("n", "<leader>sb", function()
  Snacks.picker.lines()
end, { desc = "Buffer Lines" })
vim.keymap.set("n", "<leader>sB", function()
  Snacks.picker.grep_buffers()
end, { desc = "Grep Open Buffers" })
vim.keymap.set("n", "<leader>sg", function()
  Snacks.picker.grep()
end, { desc = "Grep" })
vim.keymap.set("n", "<leader>sG", function()
  Snacks.picker.grep({ hidden = true })
end, { desc = "Grep" })
vim.keymap.set({ "n", "x" }, "<leader>sw", function()
  Snacks.picker.grep_word()
end, { desc = "Visual selection or word" })
-- search
vim.keymap.set("n", '<leader>s"', function()
  Snacks.picker.registers()
end, { desc = "Registers" })
vim.keymap.set("n", "<leader>s/", function()
  Snacks.picker.search_history()
end, { desc = "Search History" })
vim.keymap.set("n", "<leader>sa", function()
  Snacks.picker.autocmds()
end, { desc = "Autocmds" })
vim.keymap.set("n", "<leader>sb", function()
  Snacks.picker.lines()
end, { desc = "Buffer Lines" })
vim.keymap.set("n", "<leader>sc", function()
  Snacks.picker.command_history()
end, { desc = "Command History" })
vim.keymap.set("n", "<leader>sC", function()
  Snacks.picker.commands()
end, { desc = "Commands" })
vim.keymap.set("n", "<leader>sd", function()
  Snacks.picker.diagnostics()
end, { desc = "Diagnostics" })
vim.keymap.set("n", "<leader>sD", function()
  Snacks.picker.diagnostics_buffer()
end, { desc = "Buffer Diagnostics" })
vim.keymap.set("n", "<leader>sh", function()
  Snacks.picker.help()
end, { desc = "Help Pages" })
vim.keymap.set("n", "<leader>sH", function()
  Snacks.picker.highlights()
end, { desc = "Highlights" })
vim.keymap.set("n", "<leader>si", function()
  Snacks.picker.icons()
end, { desc = "Icons" })
vim.keymap.set("n", "<leader>sj", function()
  Snacks.picker.jumps()
end, { desc = "Jumps" })
vim.keymap.set("n", "<leader>sk", function()
  Snacks.picker.keymaps()
end, { desc = "Keymaps" })
vim.keymap.set("n", "<leader>sl", function()
  Snacks.picker.loclist()
end, { desc = "Location List" })
vim.keymap.set("n", "<leader>sm", function()
  Snacks.picker.marks()
end, { desc = "Marks" })
vim.keymap.set("n", "<leader>sM", function()
  Snacks.picker.man()
end, { desc = "Man Pages" })
vim.keymap.set("n", "<leader>sp", function()
  Snacks.picker.lazy()
end, { desc = "Search for Plugin Spec" })
vim.keymap.set("n", "<leader>sq", function()
  Snacks.picker.qflist()
end, { desc = "Quickfix List" })
vim.keymap.set("n", "<leader>sR", function()
  Snacks.picker.resume()
end, { desc = "Resume" })
vim.keymap.set("n", "<leader>su", function()
  Snacks.picker.undo()
end, { desc = "Undo History" })
vim.keymap.set("n", "<leader>uC", function()
  Snacks.picker.colorschemes()
end, { desc = "Colorschemes" })

-- LSP
vim.keymap.set("n", "gd", function()
  Snacks.picker.lsp_definitions()
end, { desc = "Goto Definition" })
vim.keymap.set("n", "gD", function()
  Snacks.picker.lsp_declarations()
end, { desc = "Goto Declaration" })
vim.keymap.set("n", "<leader>sr", function()
  Snacks.picker.lsp_references()
end, { nowait = true, desc = "References" })
vim.keymap.set("n", "gI", function()
  Snacks.picker.lsp_implementations()
end, { desc = "Goto Implementation" })
vim.keymap.set("n", "gy", function()
  Snacks.picker.lsp_type_definitions()
end, { desc = "Goto T[y]pe Definition" })
vim.keymap.set("n", "gs", function()
  Snacks.picker.lsp_symbols()
end, { desc = "LSP Symbols" })
vim.keymap.set("n", "gS", function()
  Snacks.picker.lsp_workspace_symbols()
end, { desc = "LSP Workspace Symbols" })
vim.keymap.set("n", "<leader>gb", function()
  Snacks.git.blame_line()
end, { desc = "Git blame line" })
