#!/bin/bash

# Path to PID file
pid_file="/home/gaurav/Desktop/trials/tmpi_trial/hello_mpi_pids.txt"

# Check if the PID file exists
if [ ! -f "$pid_file" ]; then
    echo "Error: PID file not found at $pid_file"
    exit 1
fi

# Count the number of MPI processes
num_processes=$(wc -l < "$pid_file")
echo "Found $num_processes MPI processes to debug"

# Create a modified version of nvim_mpi_debug.sh that doesn't ask for process number
modified_script="/home/gaurav/Desktop/trials/tmpi_trial/nvim_mpi_debug_auto.sh"
cat > "$modified_script" << 'EOL'
#!/bin/bash

# Auto-select process number based on OMPI_COMM_WORLD_RANK or MPI_RANK
if [ ! -z "$OMPI_COMM_WORLD_RANK" ]; then
    process_num=$((OMPI_COMM_WORLD_RANK + 1))
elif [ ! -z "$MPI_RANK" ]; then
    process_num=$((MPI_RANK + 1))
else
    # Use tmpi rank if available
    process_num=$((TMPI_RANK + 1))
fi

# Source the original script with environment variables set
export NVIM_MPI_AUTO=1
export MPI_PROCESS_NUM=$process_num

# Run the original script
/home/gaurav/Desktop/trials/tmpi_trial/nvim_mpi_debug.sh
EOL

chmod +x "$modified_script"

# Now modify the original script to accept process number via environment variable
patch_script="/home/gaurav/Desktop/trials/tmpi_trial/nvim_mpi_debug.sh.patch"
cat > "$patch_script" << 'EOL'
#!/bin/bash

# Apply patch to the original script
original_script="/home/gaurav/Desktop/trials/tmpi_trial/nvim_mpi_debug.sh"

# Make a backup
cp "$original_script" "${original_script}.bak"

# Apply the modifications
sed -i '/ Ask which process to debug/,/read -p "Enter the number of the process to debug (1-$(wc -l < "$pid_file")): " process_num/c\
# Check if auto mode is enabled\
if [ ! -z "$NVIM_MPI_AUTO" ] && [ ! -z "$MPI_PROCESS_NUM" ]; then\
    process_num=$MPI_PROCESS_NUM\
    echo "Auto-selected process number: $process_num"\
else\
    # Ask which process to debug\
    read -p "Enter the number of the process to debug (1-$(wc -l < "$pid_file")): " process_num\
fi' "$original_script"

# Skip the prompt at the end
sed -i '/read -p "Do you want to launch a new Neovim instance now? (y\/n) " launch_new/,/fi/c\
# In auto mode, always launch Neovim\
if [ ! -z "$NVIM_MPI_AUTO" ]; then\
    nvim -S "$nvim_script" "/home/gaurav/Desktop/trials/tmpi_trial/hello_mpi.cpp"\
else\
    read -p "Do you want to launch a new Neovim instance now? (y/n) " launch_new\
    if [[ "$launch_new" == "y" || "$launch_new" == "Y" ]]; then\
        nvim -S "$nvim_script" "/home/gaurav/Desktop/trials/tmpi_trial/hello_mpi.cpp"\
    fi\
fi' "$original_script"

echo "Original script patched successfully"
EOL

chmod +x "$patch_script"
bash "$patch_script"

# Create a script to send leader key command after tmpi is running
leader_script="/home/gaurav/Desktop/trials/tmpi_trial/send_leader_du.sh"
cat > "$leader_script" << 'EOL'
#!/bin/bash

# Wait for tmpi to fully initialize
sleep 2

# Send the leader key followed by 'du' to toggle UI
# Leader is space
tmux send-keys -t tmpi:0 ' du'

echo "Sent <leader>du command to all panes"
EOL

chmod +x "$leader_script"

# Now run tmpi with our script and setup the leader command to run after tmpi starts
echo "Starting tmpi with $num_processes Neovim debugger instances..."
# Start the leader script in background
($leader_script &)
# Run tmpi
tmpi $num_processes "$modified_script"

echo "Debugging session ended"
