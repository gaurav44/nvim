local M = {}

-- Helper function to get launch configurations from launch.json
local function get_launch_configurations(path)
    -- Use the vscode extension's getconfigs function
    local status_ok, vscode = pcall(require, 'dap.ext.vscode')
    if not status_ok then
      print("Error: dap.ext.vscode not found. Make sure nvim-dap is correctly installed.")
      return nil
    end
    
    -- Optional path parameter - if not provided, it uses current working directory + '/.vscode/launch.json'
    local configs = vscode.getconfigs(path) 
    
    return configs
end

-- Function to attach to an MPI process
-- @param pid The process ID to attach to
function M.attach_to_mpi_process(pid)
  local launch_configs = get_launch_configurations() 
  if launch_configs then
    launch_configs[1].processId = pid
    print(vim.inspect(launch_configs[1]))
  else
    print("Could not load launch configurations from .vscode/launch.json")
  end

  print("Attaching to MPI process with PID: " .. launch_configs[1].processId)
  print("Program: " .. launch_configs[1].program)
  print("Working directory: " .. launch_configs[1].cwd)
  
  -- Use the existing Neovim DAP setup
  local status_ok, dap = pcall(require, "dap")
  if not status_ok then
    print("ERROR: nvim-dap is not installed or not configured properly")
    return
  end
  
  -- Start debugging session
  vim.defer_fn(function()
      dap.run(launch_configs[1])
  end, 500)
end

-- Function to create a tmux grid and run commands
function M.tmgrid(panes, commands)
    if not os.getenv("TMUX") then
        print("Not inside a tmux session. Please start tmux first.")
        return
    end

    if #commands < 1 then
        print("Usage: tmgrid(panes, commands)")
        print("commands: table of commands (one per pane or one for all)")
        return
    end

    local use_multiple_commands = (#commands >= panes)
    -- Create new window
    local handle = io.popen("tmux new-window -P -F '#{window_id}'")
    local window = handle:read("*l")
    handle:close()

    -- Set window options
    os.execute("tmux set-window-option -t " .. window .. " synchronize-panes on")
    os.execute("tmux set-window-option -t " .. window .. " remain-on-exit on")

    -- Run the first command
    if use_multiple_commands then
        os.execute("tmux send-keys -t " .. window .. " '" .. commands[1] .. "' C-m")
    else
        local command = table.concat(commands, " ")
        os.execute("tmux send-keys -t " .. window .. " '" .. command .. "' C-m")
    end

    -- Create additional panes and run the commands
    for i = 2, panes do
        if use_multiple_commands and commands[i] then
            os.execute("tmux split-window -t " .. window .. " '" .. commands[i] .. "'")
        else
            local command = table.concat(commands, " ")
            os.execute("tmux split-window -t " .. window .. " '" .. command .. "'")
        end
        os.execute("tmux select-layout -t " .. window .. " tiled")
    end

    -- Switch to the window
    os.execute("tmux select-window -t " .. window)
end

-- Helper function to check if a file exists
local function file_exists(name)
    local f = io.open(name, "r")
    if f then f:close() return true else return false end
end

-- Main function to run the MPI debugging session
-- @param pid_file Path to the file containing MPI process PIDs (one per line)
-- @param source_file Path to the source file to debug
-- @param base_dir Optional base directory (defaults to current working directory)
function M.run_tmpi_debug(pid_file, source_file, base_dir)
    base_dir = base_dir or vim.fn.getcwd()
    local launch_configs = get_launch_configurations()
    
    if not launch_configs or not launch_configs[1] or not launch_configs[1].program then
        print("Error: Could not get program name from launch configuration")
        return
    end
    
    -- Get program name from launch config
    local program_path = launch_configs[1].program
    local program_name = program_path:match("([^/]+)$")
    print("Program name: " .. program_name)
    print("Source file: " .. launch_configs[1].sourceFile)
    
    -- Auto-generate PID file if not provided
    pid_file = base_dir .. "/mpi_pids.txt"
    print("Auto-generating PID file for program: " .. program_name)
    print("PID file: " .. pid_file)
    
    -- Generate PID list using the program name from launch config
    local cmd = string.format("pgrep -x %s > %s", program_name, pid_file)
    local result = os.execute(cmd)
    
    if result ~= 0 then
        -- Try again with less strict matching
        cmd = string.format("pgrep %s > %s", program_name, pid_file)
        result = os.execute(cmd)
    end

    -- Count the number of MPI processes
    local function count_lines(filename)
        local count = 0
        for _ in io.lines(filename) do count = count + 1 end
        return count
    end
    local num_processes = count_lines(pid_file)
    print("Found " .. num_processes .. " MPI processes to debug")

    local commands = {}
    for i = 1, num_processes do
        -- Read the PID directly from the file
        local pid = nil
        local count = 1
        for line in io.lines(pid_file) do
            if count == i then
                pid = line
                break
            end
            count = count + 1
        end
        
        -- Build the direct command to attach Neovim with MPIDebug
        if pid then
            -- The command that launches Neovim with the proper debugging command
            local nvim_command = string.format('nvim "%s" -c "MPIDebug %s"', 
                                            launch_configs[1].sourceFile, pid)
            table.insert(commands, nvim_command)
        end
    end

    print("Starting tmpi with " .. num_processes .. " Neovim debugger instances...")

    -- Call the Lua tmgrid function directly
    M.tmgrid(num_processes, commands)

    print("Debugging session ended")
end

-- Setup function to register commands
function M.setup()
  -- Register the MPIDebug command for individual debugger instances
  vim.api.nvim_create_user_command("MPIDebug", function(opts)
    local args = vim.split(opts.args, " ")
    local pid = tonumber(args[1])
    
    if not pid then
      vim.notify("Please provide a valid PID", vim.log.levels.ERROR)
      return
    end
    
    require("tmpi-debug").attach_to_mpi_process(pid)
  end, { nargs = "*", desc = "Attach debugger to MPI process" })
  
  -- Register the TMPIDebug command to start a full debugging grid with PID file and source file arguments
  vim.api.nvim_create_user_command("TMPIDebug", function(opts)
    local args = vim.split(opts.args, " ")
    local pid_file = args[1] -- Path to PID file 
    local source_file = args[2] -- Path to source file
    local base_dir = args[3] -- Optional base directory
    
    require("tmpi-debug").run_tmpi_debug(pid_file, source_file, base_dir)
  end, { 
    nargs = "*", 
    desc = "Start a tmux grid with MPI debugger instances", 
    complete = "file" -- Enable file path completion
  })
end

return M