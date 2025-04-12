#!/bin/bash

echo "Listing MPI process PIDs launched through hello_mpi..."

# Find hello_mpi-specific processes
pids=$(ps -ef | grep -E "hello_mpi" | grep -v grep | awk '{print $2}')

if [ -z "$pids" ]; then
    echo "No hello_mpi processes found"
    exit 0
fi

# Write PIDs to a file
pid_file="/home/gaurav/Desktop/trials/tmpi_trial/hello_mpi_pids.txt"
echo "$pids" > "$pid_file"
echo "PIDs written to $pid_file"

echo "Found the following hello_mpi processes:"
echo "PID   PPID   CMD             CMDLINE"
echo "----------------------------------------"

# Display detailed information for each process
for pid in $pids; do
    ppid=$(ps -o ppid= -p $pid 2>/dev/null || echo "N/A")
    cmd=$(ps -p $pid -o comm= 2>/dev/null || echo "Process exited")
    cmdline=$(ps -p $pid -o cmd= 2>/dev/null || echo "Process exited")
    echo "$pid   $ppid   $cmd   $cmdline"
done

echo "----------------------------------------"
echo "Total hello_mpi processes: $(echo "$pids" | wc -w)"

# More detailed hello_mpi process information
echo -e "\nDetailed hello_mpi processes:"
ps aux | grep -E "hello_mpi" | grep -v grep

# Show potential child processes that might be spawned by hello_mpi
echo -e "\nPotential hello_mpi child processes:"
children=$(pgrep -P $(echo "$pids" | tr '\n' ' ') 2>/dev/null)
if [ -n "$children" ]; then
    ps -p $children -o pid,ppid,cmd
else
    echo "No child processes found"
fi