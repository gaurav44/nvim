local M = {}

function M.setup()
  local success, toggleterm = pcall(require, "toggleterm.terminal")
  if not success then
    print("Error: toggleterm not found. Please make sure it's installed.")
    return
  end

  local build_term = toggleterm.Terminal:new({
    hidden = false,
    direction = "float",
    close_on_exit = false,
    env = {
      CLICOLOR = "1",
      CLICOLOR_FORCE = "1",
      GTEST_COLOR = "1",
      CMAKE_COLOR_DIAGNOSTICS = "1",
      GNUMAKEFLAGS = "--output-sync=target"
    }
  })

  -- Open persistent terminal
  vim.keymap.set("n", "<leader>tb", function()
    build_term:open()
    build_term:send("mkdir -p build install && clear")
  end, { noremap = true, silent = true })

  -- Select and use a CMake preset
  vim.keymap.set("n", "<leader>tp", function()
    -- Get available presets
    local handle = io.popen("cmake --list-presets")
    local result = handle:read("*a")
    handle:close()

    if not result or result == "" then
      print("No presets found.")
      return
    end

    -- Extract preset names from output
    local presets = {}
    for line in result:gmatch("[^\r\n]+") do
      if not line:match("^Available") then
        table.insert(presets, line)
      end
    end

    -- Ask user to select a preset
    vim.ui.select(presets, { prompt = "Select CMake Preset" }, function(choice)
      if choice then
        build_term:open()
        build_term:send("cmake --preset " .. choice)
      end
    end)
  end, { noremap = true, silent = true })

  -- Run Build using the selected preset
  vim.keymap.set("n", "<leader>tm", function()
    build_term:open()
    build_term:send("cmake --build build --parallel")
  end, { noremap = true, silent = true })

  -- Close terminal with 'q'
  vim.keymap.set("n", "q", function()
    build_term:close()
  end, { noremap = true, silent = true })
end

return M
