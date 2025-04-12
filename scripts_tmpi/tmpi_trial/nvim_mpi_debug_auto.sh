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
