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
