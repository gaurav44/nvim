#!/bin/bash

# Wait for tmpi to fully initialize
sleep 2

# Send the leader key followed by 'du' to toggle UI
# Leader is space
tmux send-keys -t tmpi:0 ' du'

echo "Sent <leader>du command to all panes"
