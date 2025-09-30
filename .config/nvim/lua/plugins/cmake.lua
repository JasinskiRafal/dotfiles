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
      name = "toggleterm",
      opts = {
        split_direction = "vertical",
      },
    },
    cmake_runner = {
      name = "toggleterm",
    },
  },
}
