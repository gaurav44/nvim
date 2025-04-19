local M = {}

-- Get launch configurations from launch.json
local function get_launch_configurations(path)
    local status_ok, vscode = pcall(require, 'dap.ext.vscode')
    if not status_ok then
        print("Error: dap.ext.vscode not found. Ensure nvim-dap is installed.")
        return nil
    end
    return vscode.getconfigs(path)
end

-- Attach to an MPI process
function M.attach_to_mpi_process(pid)
    local launch_configs = get_launch_configurations()
    launch_configs[1].processId = pid
    local _, dap = pcall(require, "dap")

    vim.defer_fn(function()
        dap.run(launch_configs[1])
    end, 500)
end

-- Create a tmux grid and run commands
function M.tmgrid(panes, commands)
    if not os.getenv("TMUX") then
        print("Not inside a tmux session. Start tmux first.")
        return
    end

    local handle = io.popen("tmux new-window -P -F '#{window_id}'")
    local window = handle:read("*l")
    handle:close()

    os.execute("tmux set-window-option -t " .. window .. " synchronize-panes on")
    os.execute("tmux set-window-option -t " .. window .. " remain-on-exit on")

    for i = 1, panes do
        local command = commands[i] or table.concat(commands, " ")
        local cmd = i == 1 and "tmux send-keys -t " .. window .. " '" .. command .. "' C-m"
                    or "tmux split-window -t " .. window .. " '" .. command .. "'"
        os.execute(cmd)
        os.execute("tmux select-layout -t " .. window .. " tiled")
    end

    os.execute("tmux select-window -t " .. window)
end

-- Main function to run the MPI debugging session
function M.run_tmpi_debug(pid_file, source_file, base_dir)
    base_dir = base_dir or vim.fn.getcwd()
    local launch_configs = get_launch_configurations()

    local program_name = launch_configs[1].program:match("([^/]+)$")
    pid_file = base_dir .. "/mpi_pids.txt"
    os.execute(string.format("pgrep -x %s > %s", program_name, pid_file))

    local commands = {}
    local num_processes = 0
    for line in io.lines(pid_file) do
        num_processes = num_processes + 1
        local nvim_command = string.format('nvim "%s" -c "MPIDebug %s"', launch_configs[1].sourceFile, line)
        table.insert(commands, nvim_command)
    end

    M.tmgrid(num_processes, commands)
end

-- Setup function to register commands
function M.setup()
    vim.api.nvim_create_user_command("MPIDebug", function(opts)
        local pid = tonumber(vim.split(opts.args, " ")[1])
        if pid then
            M.attach_to_mpi_process(pid)
        else
            vim.notify("Please provide a valid PID", vim.log.levels.ERROR)
        end
    end, { nargs = "*" })

    vim.api.nvim_create_user_command("TMPIDebug", function(opts)
        local args = vim.split(opts.args, " ")
        M.run_tmpi_debug(args[1], args[2], args[3])
    end, { nargs = "*", complete = "file" })
end

return M