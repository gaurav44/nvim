#!/bin/bash

# filepath: /home/gauravgokhale/.config/nvim/scripts_tmpi/tmpi_trial/nvim_mpi_debug.sh
# Path to PID file and source file
BASE_DIR="/home/gauravgokhale/.config/nvim/scripts_tmpi/tmpi_trial"
pid_file="$BASE_DIR/hello_mpi_pids.txt"
SOURCE_FILE="$BASE_DIR/hello_mpi.cpp"
PROGRAM_PATH="/home/gauravgokhale/.config/nvim/scripts_tmpi/tmpi_trial/hello_mpi"

# Get process index from command line argument
process_num=${1:-1}  # Default to 1 if not provided

# Check if the PID file exists
if [ ! -f "$pid_file" ]; then
    echo "Error: PID file not found at $pid_file"
    echo "Please run start_mpi_processes.sh first to generate the file."
    exit 1
fi

# Get total number of MPI processes
total_procs=$(wc -l < "$pid_file")

# Validate process number
if [ "$process_num" -gt "$total_procs" ] || [ "$process_num" -lt 1 ]; then
    echo "Error: Invalid process number: $process_num. Valid range is 1-$total_procs"
    exit 1
fi

# Get the selected PID based on process_num
selected_pid=$(sed -n "${process_num}p" "$pid_file")
if [ -z "$selected_pid" ]; then
    echo "Error: Could not find PID for process $process_num"
    exit 1
fi

# Verify that the process is still running
if ! ps -p $selected_pid > /dev/null; then
    echo "Error: Process with PID $selected_pid is not running"
    exit 1
fi

echo "Attaching to MPI process $process_num with PID: $selected_pid"

# Launch Neovim and use the MPIDebug command to attach
# nvim "$SOURCE_FILE" -c "MPIDebug $selected_pid"
nvim "$SOURCE_FILE" -c "MPIDebug $selected_pid $PROGRAM_PATH $BASE_DIR"

echo "Debug session for process $process_num ended"