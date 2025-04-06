local M = {}

function M.setup()
  -- Select and use a CMake preset
  vim.keymap.set("n", "<leader>cm", function()
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
        -- Create appropriate directories based on the preset
        if string.match(choice:lower(), "debug") then
          os.execute("mkdir -p build-debug install-debug")
        else
          os.execute("mkdir -p build install")
        end
        
        -- Always send command to the terminal window
        vim.cmd('silent !tmux select-window -t terminal && tmux send-keys "cmake --preset ' .. choice .. '" Enter')
        
        -- Switch back to the current window
        -- vim.cmd('silent !tmux select-window -t editor')
      end
    end)
  end, { noremap = true, silent = true, desc = 'Select CMake Preset' })

  -- Run Build using release mode
  vim.keymap.set("n", "<leader>cr", function()
    -- Create build directory if it doesn't exist
    os.execute("mkdir -p build")
    
    -- Send command directly to terminal window
    vim.cmd('silent !tmux select-window -t terminal && tmux send-keys "cmake --build build --parallel 2" Enter')
    
    -- Switch back to the editor window
    -- vim.cmd('silent !tmux select-window -t editor')
  end, { noremap = true, silent = true, desc = 'Build Release' })

  -- Run Build in Debug mode
  vim.keymap.set("n", "<leader>cd", function()
    -- Create build-debug directory if it doesn't exist
    os.execute("mkdir -p build-debug")
    
    -- Send command directly to terminal window
    vim.cmd('silent !tmux select-window -t terminal && tmux send-keys "cmake --build build-debug --parallel 2" Enter')
    
    -- Switch back to the editor window
    -- vim.cmd('silent !tmux select-window -t editor')
  end, { noremap = true, silent = true, desc = 'Build Debug' })

  -- Close terminal with 'q' (for the terminal pane in tmux)
  -- vim.keymap.set("t", "q", function()
  --   vim.cmd('silent !tmux kill-pane')
  -- end, { noremap = true, silent = true })
end

-- Add this function to register with which-key
function M.register_which_key(wk)
  wk.register({
    c = {
      name = "CMake",
      m = { "<cmd>lua require('cmake-mappings').setup()<CR>", "Select CMake Preset" },
    },
    b = {
      name = "Build",
      r = { "<cmd>lua require('cmake-mappings').setup()<CR>", "Build Release" },
      d = { "<cmd>lua require('cmake-mappings').setup()<CR>", "Build Debug" },
    },
  }, { prefix = "<leader>" })
end

return M
