" Check if we're inside Neovim
if has('nvim')
  " Attach to the MPI process using nvim-dap
  lua << EOF
  local pid = 645129
  print("Attaching to MPI process with PID: " .. pid)
  
  -- Use the existing Neovim DAP setup
  local status_ok, dap = pcall(require, "dap")
  if not status_ok then
    print("ERROR: nvim-dap is not installed or not configured properly")
    print("Please make sure nvim-dap is installed in your Neovim configuration")
    return
  end
  
  -- Load the debug configuration
  local config_file = io.open("/home/gaurav/Desktop/trials/tmpi_trial/debug_config.json", "r")
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

" Create commands to modify the volatile int debug flag
command! -nargs=1 SetDebugFlag lua require('dap').eval('debug_flag = <args>')
command! ContinueDebug lua require('dap').eval('debug_flag = 1')
command! PauseDebug lua require('dap').eval('debug_flag = 0')

" Automatically toggle the DAP UI when starting
lua << EOF
vim.defer_fn(function()
  -- Execute the DAP UI toggle command (equivalent to <leader>du)
  vim.cmd('lua require("dapui").toggle()')
  print("DAP UI automatically toggled")
end, 1000)
EOF

" Print instructions for using the commands
lua << EOF
print("----------------------------------------------------------------")
print("DEBUGGING INSTRUCTIONS:")
print("After the debugger attaches, you can use the following commands:")
print("  :SetDebugFlag 1    # Set debug flag to specific value")
print("  :ContinueDebug     # Set flag to 1 to continue execution")
print("  :PauseDebug        # Set flag to 0 to pause at next checkpoint")
print("----------------------------------------------------------------")
EOF
