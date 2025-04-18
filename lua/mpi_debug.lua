local M = {}

-- Function to attach to an MPI process
-- @param pid The process ID to attach to
-- @param program The path to the program executable
-- @param cwd The current working directory for the debug session
function M.attach_to_mpi_process(pid, program, cwd)
  -- Set default values if not provided
  program = program or "/home/gauravgokhale/.config/nvim/scripts_tmpi/tmpi_trial/hello_mpi"
  cwd = cwd or "/home/gauravgokhale/.config/nvim/scripts_tmpi/tmpi_trial"
  
  print("Attaching to MPI process with PID: " .. pid)
  print("Program: " .. program)
  print("Working directory: " .. cwd)
  
  -- Use the existing Neovim DAP setup
  local status_ok, dap = pcall(require, "dap")
  if not status_ok then
    print("ERROR: nvim-dap is not installed or not configured properly")
    print("Please make sure nvim-dap is installed in your Neovim configuration")
    return
  end
  
  -- Create debug configuration on the fly
  local config = {
    configurations = {
        {
          type = "cppdbg",
          request = "attach",
          name = "MPI Process Attach",
          processId = pid,
          program = program,
          cwd = cwd,
          stopAtEntry = true,
          setupCommands = {
            {
              text = "-enable-pretty-printing",
              description = "Enable pretty printing",
              ignoreFailures = true
            }
          }
        }
    }
  }
  
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
end

function M.setup()
  vim.api.nvim_create_user_command("MPIDebug", function(opts)
    local args = vim.split(opts.args, " ")
    local pid = tonumber(args[1])
    local program = args[2]
    local cwd = args[3]
    
    if not pid then
      vim.notify("Please provide a valid PID", vim.log.levels.ERROR)
      return
    end
    
    require("mpi_debug").attach_to_mpi_process(pid, program, cwd)
  end, { nargs = "*", desc = "Attach debugger to MPI process with optional program path and working directory" })
end

return M