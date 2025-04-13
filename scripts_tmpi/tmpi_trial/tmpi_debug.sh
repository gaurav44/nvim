#!/bin/bash

# Path to PID file
BASE_DIR="/home/gauravgokhale/.config/nvim/scripts_tmpi/tmpi_trial"
pid_file="$BASE_DIR/hello_mpi_pids.txt"

# Check if the PID file exists
if [ ! -f "$pid_file" ]; then
    echo "Error: PID file not found at $pid_file"
    echo "Make sure you've run start_mpi_processes.sh first."
    exit 1
fi

# Count the number of MPI processes
num_processes=$(wc -l < "$pid_file")
echo "Found $num_processes MPI processes to debug"

# Verify the main script exists
main_script="$BASE_DIR/nvim_mpi_debug.sh"

if [ ! -f "$main_script" ]; then
    echo "Error: Main script not found at $main_script"
    exit 1
fi

# Ensure the script is executable
chmod +x "$main_script" 2>/dev/null

# Create command array with a unique process index for each pane
commands=()
for i in $(seq 1 $num_processes); do
    commands+=("$main_script $i")
done

echo "Starting tmpi with $num_processes Neovim debugger instances..."
# Run tmgrid with the array of commands
"$BASE_DIR/tmgrid.sh" $num_processes "${commands[@]}"

echo "Debugging session ended"