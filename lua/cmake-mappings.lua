local M = {}

function M.setup()
  -- Open a persistent terminal and create necessary directories
  vim.keymap.set("n", "<leader>tb", function()
    vim.cmd('silent !tmux split-window -h "mkdir -p build install && clear"')
  end, { noremap = true, silent = true })

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
        -- Check if a shell pane exists
        local check_pane = io.popen('tmux list-panes -F "#{pane_current_command}" | grep -q "zsh\\|bash\\|fish" && echo "exists"')
        local pane_exists = check_pane:read("*a")
        check_pane:close()

        if pane_exists:match("exists") then
          -- Send command to the existing shell pane
          vim.cmd('silent !tmux send-keys -t "{last}" "cmake --preset ' .. choice .. '" Enter')
        else
          -- Create a new split and run the command
          vim.cmd('silent !tmux split-window -h "cmake --preset ' .. choice .. '; exec $SHELL"')
        end
      end
    end)
  end, { noremap = true, silent = true })

  -- Run Build using release mode 
  vim.keymap.set("n", "<leader>br", function()
    -- Check if a shell pane exists
    local check_pane = io.popen('tmux list-panes -F "#{pane_current_command}" | grep -q "zsh\\|bash\\|fish" && echo "exists"')
    local pane_exists = check_pane:read("*a")
    check_pane:close()

    if pane_exists:match("exists") then
      -- Send command to the existing shell pane
      vim.cmd('silent !tmux send-keys -t "{last}" "cmake --build build --parallel 36" Enter')
    else
      -- Create a new split and run the command
      vim.cmd('silent !tmux split-window -h "cmake --build build --parallel 36; exec $SHELL"')
    end
  end, { noremap = true, silent = true })

  --Run Build in Debug mode using the selected preset
  vim.keymap.set("n", "<leader>bd", function()
    --Check if a shell pane exists
    local check_pane = io.popen('tmux list-panes -F "#{pane_current_command}" | grep -q "zsh\\|bash\\|fish" && echo "exists"')
    local pane_exists = check_pane:read("*a")
    check_pane:close()

    if pane_exists:match("exists") then 
      --Send command to the existing shell pane
      vim.cmd('silent !tmux send-keys -t "{last}" "cmake --build build-debug --parallel 36" Enter')
    else
      --Create a new split and run the command
      vim.cmd('silent !tmux split-window -h "cmake --build build-debug --parallel 36; exec $SHELL"')
    end
  end, {noremap = true, silent = true})

  -- Close terminal with 'q' (for the terminal pane in tmux)
  vim.keymap.set("t", "q", function()
    vim.cmd('silent !tmux kill-pane')
  end, { noremap = true, silent = true })
end

return M
