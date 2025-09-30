return {
  "Civitasv/cmake-tools.nvim",
  dependencies = {
    "akinsho/toggleterm.nvim",
  },
  opts = {
    cmake_regenerate_on_save = false,
    cmake_dap_configuration = {
      type = "cppdbg",
    },
    cmake_executor = {
      name = "terminal",
      opts = {
        split_direction = "vertical",
        split_size = 100,
      },
    },
    cmake_runner = {
      name = "terminal",
      opts = {
        split_direction = "vertical",
        split_size = 100,
      },
    },
  },
}
