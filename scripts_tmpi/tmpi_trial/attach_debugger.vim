" Check if we're inside Neovim
if has('nvim')
  " Attach to the MPI process using nvim-dap
  lua << EOF
  local pid = 13173
  print("Attaching to MPI process with PID: " .. pid)
  
  -- Use the existing Neovim DAP setup
  local status_ok, dap = pcall(require, "dap")
  if not status_ok then
    print("ERROR: nvim-dap is not installed or not configured properly")
    print("Please make sure nvim-dap is installed in your Neovim configuration")
    return
  end
  
  -- Load the debug configuration
  local config_file = io.open("/home/gauravgokhale/.config/nvim/scripts_tmpi/tmpi_trial/debug_config.json", "r")
  if not config_file then
    print("ERROR: Could not open debug configuration file")
    return
  end
  
  local config_content = config_file:read("*all")
  config_file:close()
  
  local config = vim.json.decode(config_content)
  
  -- Set the configuration
  if config and config.configurations and config.configurations[1] then
    -- Configure for C/C++
    dap.configurations.cpp = dap.configurations.cpp or {}
    table.insert(dap.configurations.cpp, config.configurations[1])
    dap.configurations.c = dap.configurations.c or {}
    table.insert(dap.configurations.c, config.configurations[1])
    
    -- Start debugging session
    vim.defer_fn(function()
      dap.run(config.configurations[1])
    end, 500)
  end
EOF
else
  echo "This script requires Neovim"
endif
