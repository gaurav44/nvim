#!/bin/bash

# Configuration variables
MPI_PROGRAM="/home/gaurav/Desktop/trials/tmpi_trial/hello_mpi"
NUM_PROCESSES=9
BASE_DIR="/home/gaurav/Desktop/trials/tmpi_trial"

# Clean up any existing wait files
rm -f $BASE_DIR/.wait_* 2>/dev/null

# Create the debug helper header
DEBUG_HELPER="$BASE_DIR/debug_helper.h"
echo "Creating updated debug helper at $DEBUG_HELPER"
cat > "$DEBUG_HELPER" << 'EOL'
#ifndef DEBUG_HELPER_H
#define DEBUG_HELPER_H

#include <stdio.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <stdbool.h>
#include <signal.h>
#include <stdlib.h>
#include <time.h>

/**
 * Wait for a file to be modified (no timeout)
 */
static inline void wait_for_debugger() {
    pid_t pid = getpid();
    char wait_file[256];
    snprintf(wait_file, sizeof(wait_file), "/home/gaurav/Desktop/trials/tmpi_trial/.wait_%d", pid);
    
    // Create the wait file with timestamp
    FILE* fp = fopen(wait_file, "w");
    if (!fp) {
        printf("[PID %d] Could not create wait file, continuing without waiting.\n", pid);
        return;
    }
    
    // Write the current time to the file
    time_t current_time = time(NULL);
    fprintf(fp, "Created: %ld\nPID: %d\n", current_time, pid);
    fclose(fp);
    
    // Get the initial modification time
    struct stat file_stat;
    if (stat(wait_file, &file_stat) != 0) {
        printf("[PID %d] Could not stat wait file, continuing without waiting.\n", pid);
        return;
    }
    time_t initial_mtime = file_stat.st_mtime;
    
    printf("[PID %d] Waiting for debugger. To continue, modify file: %s\n", pid, wait_file);
    printf("[PID %d] You can use: echo 'continue' >> %s\n", pid, wait_file);
    
    // Wait until the file is modified - no timeout
    int waited = 0;
    while (1) {
        // Check if the file has been modified
        if (stat(wait_file, &file_stat) != 0) {
            printf("[PID %d] Wait file removed, continuing execution.\n", pid);
            break;
        }
        
        if (file_stat.st_mtime > initial_mtime) {
            printf("[PID %d] Wait file modified, continuing execution.\n", pid);
            break;
        }
        
        sleep(1);
        waited++;
        
        if (waited % 10 == 0) {
            printf("[PID %d] Still waiting... (%d seconds)\n", pid, waited);
        }
    }
    
    printf("[PID %d] Continuing execution.\n", pid);
    // Don't remove the file so we can see it was processed
}

#endif /* DEBUG_HELPER_H */
EOL

# Check if we need to compile with debug helper
read -p "Do you need to recompile your program with debug helper? (y/n) " recompile
if [[ "$recompile" == "y" || "$recompile" == "Y" ]]; then
    # Assuming hello_mpi.c or hello_mpi.cpp exists
    if [ -f "$BASE_DIR/hello_mpi.c" ]; then
        SRC_FILE="$BASE_DIR/hello_mpi.c"
    elif [ -f "$BASE_DIR/hello_mpi.cpp" ]; then
        SRC_FILE="$BASE_DIR/hello_mpi.cpp"
    else
        echo "Error: Could not find source file (hello_mpi.c or hello_mpi.cpp)"
        exit 1
    fi
    
    echo "Adding debug helper include to $SRC_FILE..."
    # Check if the header is already included
    if ! grep -q "#include \"debug_helper.h\"" "$SRC_FILE"; then
        # Create a backup of the original file
        cp "$SRC_FILE" "${SRC_FILE}.bak"
        
        # Add the include at the beginning of the file after existing includes
        awk '
        /^#include/ { print; next; }
        !header_added { print "#include \"debug_helper.h\""; header_added=1; }
        { print; }
        ' "${SRC_FILE}.bak" > "$SRC_FILE"
    fi
    
    # Find a suitable place to add the wait_for_debugger call (after MPI_Init)
    if grep -q "MPI_Init" "$SRC_FILE"; then
        if ! grep -q "wait_for_debugger" "$SRC_FILE"; then
            cp "$SRC_FILE" "${SRC_FILE}.add"
            awk '
            /MPI_Init/ {
                print;
                print "    // Wait for debugger to attach";
                print "    wait_for_debugger();";
                next;
            }
            { print; }
            ' "${SRC_FILE}.add" > "$SRC_FILE"
        fi
    else
        echo "Warning: MPI_Init not found in source file. You'll need to add wait_for_debugger() manually."
    fi
    
    # Compile with debug flags
    echo "Compiling with debug information..."
    mpicc -g -O0 "$SRC_FILE" -o "$MPI_PROGRAM"
    if [ $? -ne 0 ]; then
        echo "Compilation failed!"
        exit 1
    fi
    echo "Compilation successful."
fi

# Clear any existing signal files to avoid issues
rm -f $BASE_DIR/.debug_ready_* 2>/dev/null

# Start MPI processes
echo "Starting $NUM_PROCESSES MPI processes..."
mpirun -np $NUM_PROCESSES --oversubscribe "$MPI_PROGRAM" &
MPI_PID=$!

# Save process information for the debugger
sleep 1  # Give MPI processes time to start

# Find all MPI process PIDs and save them to a file
echo "Finding MPI process PIDs..."
ps -ef | grep "$MPI_PROGRAM" | grep -v grep | awk '{print $2}' > "$BASE_DIR/hello_mpi_pids.txt"

echo "MPI processes started. PIDs saved to $BASE_DIR/hello_mpi_pids.txt"
cat "$BASE_DIR/hello_mpi_pids.txt"

# Create a helper script to resume processes
cat > "$BASE_DIR/resume_process.sh" << 'EOL'
#!/bin/bash
if [ -z "$1" ]; then
  echo "Usage: $0 <pid>"
  echo "  Signals the process with PID to continue execution"
  exit 1
fi

WAIT_FILE="/home/gaurav/Desktop/trials/tmpi_trial/.wait_$1"
if [ -f "$WAIT_FILE" ]; then
  echo "Signaling process $1 to continue..."
  echo "continue - $(date)" >> "$WAIT_FILE"
  echo "Process $1 signaled to continue."
else
  echo "Wait file for PID $1 not found."
  echo "Make sure the process is running and waiting."
fi
EOL
chmod +x "$BASE_DIR/resume_process.sh"

echo ""
echo "The processes will wait indefinitely for you to modify their wait files."
echo "Wait files will be created at $BASE_DIR/.wait_PID"
echo ""
echo "To continue a specific process:"
echo "  ./resume_process.sh <PID>"
echo ""
echo "To attach a debugger to a process:"
echo "  1. Use VS Code with the MPI debug attach configuration"
echo "  2. After attaching debugger, let the process continue with:"
echo "     ./resume_process.sh <PID>"
echo ""
echo "To continue all processes at once:"
for pid in $(cat "$BASE_DIR/hello_mpi_pids.txt"); do
  echo "  ./resume_process.sh $pid"
done

# Wait for all processes to finish
wait $MPI_PID
echo "All MPI processes have finished."
