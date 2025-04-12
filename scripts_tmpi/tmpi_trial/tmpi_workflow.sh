#!/bin/bash

# Path to the file containing PIDs
pid_file="/home/gaurav/Desktop/trials/tmpi_trial/hello_mpi_pids.txt"

# Check if the file exists
if [ ! -f "$pid_file" ]; then
    echo "Error: PID file $pid_file not found!"
    echo "Please run mpi_debug.sh first to generate the PID file."
    exit 1
fi

# Read PIDs from the file
pids=$(cat "$pid_file")

# Check if the file has any content
if [ -z "$pids" ]; then
    echo "No PIDs found in $pid_file"
    exit 1
fi

echo "Found $(echo "$pids" | wc -w) PIDs from hello_mpi processes:"
echo "$pids"

# Verify that the processes are still running
echo "Verifying processes are still active..."
active_pids=""
for pid in $pids; do
    if ps -p $pid > /dev/null; then
        echo "PID $pid is active"
        active_pids="$active_pids $pid"
    else
        echo "PID $pid is no longer active"
    fi
done

# Initialize tmpi workflow with active PIDs
if [ -n "$active_pids" ]; then
    echo "Setting up tmpi workflow with active PIDs: $active_pids"
    # This is where you would add your tmpi-specific commands
    # For example:
    # tmpi init $active_pids
    echo "tmpi workflow initialized and ready for further actions"
else
    echo "No active PIDs found. Cannot initialize tmpi workflow."
    exit 1
fi
