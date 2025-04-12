#include <mpi.h>
#include <stdio.h>
#include <unistd.h>

// Volatile debug flag for debugger-controlled execution
volatile int debug_flag = 0;

int main(int argc, char** argv) {
    // Initialize the MPI environment
    MPI_Init(&argc, &argv);

    // Get the number of processes and rank of the process
    int world_size, world_rank;
    MPI_Comm_size(MPI_COMM_WORLD, &world_size);
    MPI_Comm_rank(MPI_COMM_WORLD, &world_rank);

    // Get the name of the processor
    char processor_name[MPI_MAX_PROCESSOR_NAME];
    int name_len;
    MPI_Get_processor_name(processor_name, &name_len);

    // Print initial message
    printf("Hello from processor %s, rank %d out of %d processors\n",
           processor_name, world_rank, world_size);

    // Debug checkpoint 1
    printf("Process %d: Waiting at debug checkpoint 1\n", world_rank);
    while (debug_flag == 0) {
        // Wait until debugger sets the flag to 1
        usleep(100000); // 100ms sleep to reduce CPU usage
    }
    
    // Continue with program execution
    printf("Process %d: Continuing after checkpoint 1\n", world_rank);
    
    // Reset debug flag for next checkpoint
    debug_flag = 0;
    
    // Do some work
    for (int i = 0; i < 5; i++) {
        printf("Process %d: Working step %d\n", world_rank, i);
        sleep(1);
    }
    
    // Debug checkpoint 2
    printf("Process %d: Waiting at debug checkpoint 2\n", world_rank);
    while (debug_flag == 0) {
        // Wait until debugger sets the flag to 1
        usleep(100000); // 100ms sleep to reduce CPU usage
    }
    
    printf("Process %d: Continuing after checkpoint 2\n", world_rank);
    
    // Finalize the MPI environment
    MPI_Finalize();
    return 0;
}