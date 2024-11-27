#!/bin/sh

# Path to the session file
SESSION_FILE="$HOME/.config/custom_scripts/saved_sessions.txt"

# Check if the session file exists
if [ ! -f "$SESSION_FILE" ]; then
    echo "Session file not found: $SESSION_FILE"
    exit 1
fi

# Extract unique session names using `awk` and pass them to `fzf`
SESSION_NAME=$(awk -F ':' '{print $1}' "$SESSION_FILE" | sort -u | fzf --reverse --info right --prompt "Select a session: " --border "rounded" --border-label "WORK PROJECTS" --preview "grep -e '^{}' $SESSION_FILE | column -t -s ':'" --preview-window=right:65%)

# Check if a session was selected
if [ -z "$SESSION_NAME" ]; then
    echo "No session selected."
    exit 1
fi

# Grep the session from the session file
SESSION=$(grep "^$SESSION_NAME:" "$SESSION_FILE")

# Check if the tmux session already exists
if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    # echo "Attaching to existing session: $SESSION_NAME"
    tmux attach-session -t "$SESSION_NAME"
    exit 0
fi

echo "$SESSION" | while IFS=: read -r session window window_name path command; do
    # echo "Restoring and attaching to session here: $session"
    # Create the session if it doesn't exist
    tmux has-session -t "$session" 2>/dev/null || tmux new-session -d -s "$session"
    #
    # echo "Restoring and attaching to session window: $session:$window"
    # # Create the window if it doesn't exist
    tmux new-window -t "$session:$window" -n "$window_name" 2>/dev/null
    #
    # # Navigate to the working directory
    # echo "Restoring and attaching to session path: $path"
    # echo "Restoring and attaching to session pane: $pane"
    # echo "Restoring and attaching to session window_name: $window_name"
    tmux send-keys -t "$session:$window" "cd $path" C-m
    #
    # echo "Restoring and attaching to session command: $command"
    # # Run the command
    tmux send-keys -t "$session:$window" "$command" C-m
done

# echo "$SESSION"
# Attach to the restored session
tmux attach-session -t "$SESSION_NAME"
