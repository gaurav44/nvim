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
