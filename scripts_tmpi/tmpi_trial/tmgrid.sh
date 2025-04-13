#!/bin/bash
# filepath: /home/gauravgokhale/.config/nvim/scripts_tmpi/tmgrid

usage() {
    echo 'tmgrid: Run multiple commands as a grid in a tmux window with synchronized keyboard input.'
    echo ''
    echo 'Usage:'
    echo '   tmgrid [number] [command1] [command2] ... [commandN]'
    echo '   or'
    echo '   tmgrid [number] [single_command]'
    echo ''
    echo 'The first argument is the number of panes to create, followed by either:'
    echo '- Multiple commands (one per pane)'
    echo '- A single command to run in all panes'
    echo ''
    echo 'The new window is set to remain on exit and has to be closed manually. ("C-b + &" by default)'
    echo 'By default the panes in the window are synchronized. To work with one pane, maximize it ("C-b + z").'
}

if [[ ${#} -lt 2 ]]; then
    usage
    exit 1
fi

if [[ -z ${TMUX+x} ]]; then
    # Not in a tmux session, start a new one
    socket=$(mktemp --dry-run tmgrid.XXXX)
    exec tmux ${TMGRID_TMUX_OPTIONS:-} -L ${socket} new-session "${0} ${*}"
fi

# Extract arguments
panes=${1}
shift

# Check if we have multiple commands or just one
use_multiple_commands=0
if [[ $# -ge $panes ]]; then
    use_multiple_commands=1
fi

# Create new window with the first pane
window_info=$(tmux new-window -P -F '#{window_id}')
window=${window_info}

# Set window options
tmux set-window-option -t ${window} synchronize-panes on
tmux set-window-option -t ${window} remain-on-exit on

# Run the first command
if [[ $use_multiple_commands -eq 1 ]]; then
    tmux send-keys -t ${window} "$1" C-m
    shift
else
    command="$@"
    tmux send-keys -t ${window} "$command" C-m
fi

# Create additional panes and run the commands
for ((i=1; i<panes; i++)); do
    if [[ $use_multiple_commands -eq 1 && $# -gt 0 ]]; then
        tmux split-window -t ${window} "$1"
        shift
    else
        tmux split-window -t ${window} "$command"
    fi
    tmux select-layout -t ${window} tiled
done

# Switch to the window
tmux select-window -t ${window}