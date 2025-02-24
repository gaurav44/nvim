return {
  "Civitasv/cmake-tools.nvim",
  dependencies = { "nvim-lua/plenary.nvim", "akinsho/toggleterm.nvim" },
  config = function()
    local osys = require("cmake-tools.osys")
    local cmake_tools = require("cmake-tools")

    -- Custom function to generate CMake with user-defined options
    function _G.CMakeGenerateWithOptions()
      local user_options = vim.fn.input("CMake options: ") -- Prompt user for options
      local command = ":CMakeGenerate " .. user_options
      vim.cmd(command)                                     -- Execute the command with user input
    end

    cmake_tools.setup({
      cmake_command = "cmake",                                          -- specify cmake command path
      ctest_command = "ctest",                                          -- specify ctest command path
      cmake_use_preset = true,
      cmake_regenerate_on_save = true,                                  -- auto generate when save CMakeLists.txt
      cmake_generate_options = { "-DCMAKE_EXPORT_COMPILE_COMMANDS=1", "--trace" }, -- default option can remain here
      cmake_build_options = {},                                         -- options for CMakeBuild
      --cmake_build_directory = "build",
      cmake_build_directory = function()
        if osys.iswin32 then
          return "out\\${variant:buildType}"
        end
        return "out/${variant:buildType}"
      end,                                     -- generate directory for cmake, allows macro expansion
      cmake_soft_link_compile_commands = true, -- link compile commands file to project root
      cmake_compile_commands_from_lsp = false, -- set compile commands file location using LSP
      cmake_kits_path = nil,                   -- specify global cmake kits path
      cmake_variants_message = {
        short = { show = true },
        long = { show = true, max_length = 40 },
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
      cmake_virtual_text_support = false, -- Show target related to current file using virtual text
    })

    -- Key mapping to call the custom function
    vim.api.nvim_set_keymap(
      "n",
      "\\cg",
      ":lua CMakeGenerateWithOptions()<CR>",
      { noremap = true, silent = true }
    )
    vim.api.nvim_set_keymap("n", "\\cb", ":CMakeBuild<CR>", { noremap = true, silent = true }) -- Build
    vim.api.nvim_set_keymap("n", "\\cr", ":CMakeRun<CR>", { noremap = true, silent = true })   -- Run

    -- Add key mapping for running with preset
    vim.api.nvim_set_keymap(
      "n",
      "\\cp", -- You can change this to any key binding you prefer
      ":lua CMakeRunWithPreset()<CR>",
      { noremap = true, silent = true }
    )
  end,
}
