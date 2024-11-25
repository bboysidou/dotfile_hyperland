#!/bin/sh

# Path to the session file
SESSION_FILE="$HOME/.config/custom_scripts/saved_sessions.txt"

# Check if the session file exists
if [ ! -f "$SESSION_FILE" ]; then
    echo "Session file not found: $SESSION_FILE"
    exit 1
fi

# Extract unique session names using `awk` and pass them to `fzf`
SESSION_NAME=$(awk -F ':' '{print $1}' "$SESSION_FILE" | sort -u | fzf --preview "grep -e '^{}' $SESSION_FILE | column -t -s ':'" --preview-window=up:5:wrap)

# Check if a session was selected
if [ -z "$SESSION_NAME" ]; then
    echo "No session selected."
    exit 1
fi

# Check if the tmux session already exists
# if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
#     echo "Attaching to existing session: $SESSION_NAME"
#     tmux attach-session -t "$SESSION_NAME"
#     exit 0
# fi

# If the session doesn't exist, restore it from the session file
echo "Restoring and attaching to session: $SESSION_NAME"
SESSION="grep -e '^$SESSION_NAME' $SESSION_FILE | column -t -s ':'"
# grep -e "^$SESSION_NAME" "$SESSION_FILE" | while IFS=: read -r session window pane path command; do
#     # Create the session if it doesn't exist
#     tmux has-session -t "$session" 2>/dev/null || tmux new-session -d -s "$session"
#
#     # Create the window if it doesn't exist
#     tmux new-window -t "$session:$window" -n "window-$window" 2>/dev/null
#
#     # Navigate to the working directory
#     tmux send-keys -t "$session:$window.$pane" "cd $path" C-m
#
#     # Run the command
#     tmux send-keys -t "$session:$window.$pane" "$command" C-m
# done

echo "Session restored and attached to: $SESSION"
# Attach to the restored session
# tmux attach-session -t "$SESSION_NAME"
