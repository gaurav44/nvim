return {
  "Civitasv/cmake-tools.nvim",
  dependencies = { "nvim-lua/plenary.nvim", "akinsho/toggleterm.nvim" },
  config = function()
    local cmake_tools = require("cmake-tools")

    -- Custom function to generate CMake with user-defined options
    function _G.CMakeGenerateWithOptions()
      local user_options = vim.fn.input("CMake options: ") -- Prompt user for options
      local command = ":CMakeGenerate " .. user_options
      vim.cmd(command)                                  -- Execute the command with user input
    end

    cmake_tools.setup({
      cmake_command = "cmake",
      cmake_build_directory = "build",
      cmake_build_type = "Debug",
      cmake_generate_options = {
        "-DCMAKE_EXPORT_COMPILE_COMMANDS=1", -- Default option can remain here
      },

      cmake_executor = {
        name = "toggleterm",
        opts = {
          direction = "horizontal",
          close_on_exit = false,
          auto_scroll = true,
          singleton = true,
        },
      },

      cmake_runner = {
        name = "toggleterm",
        opts = {
          direction = "horizontal",
          close_on_exit = false,
          auto_scroll = true,
          singleton = true,
        },
      },

      cmake_notifications = {
        runner = { enabled = false },
        executor = { enabled = false },
      },

      cmake_virtual_text_support = false,
      cmake_variants_message = {
        short = { show = false },
        long = { show = false },
      },
    })

    -- Key mapping to call the custom function
    vim.api.nvim_set_keymap(
      "n",
      "\\cg",
      ":lua CMakeGenerateWithOptions()<CR>",
      { noremap = true, silent = true }
    )
    vim.api.nvim_set_keymap("n", "\\cb", ":CMakeBuild<CR>", { noremap = true, silent = true }) -- Build
    vim.api.nvim_set_keymap("n", "\\cr", ":CMakeRun<CR>", { noremap = true, silent = true }) -- Run
  end,
}
