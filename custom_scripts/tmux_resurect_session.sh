#!/bin/sh

SESSION_FILE="$HOME/.config/custom_scripts/saved_sessions.txt"

if [ ! -f "$SESSION_FILE" ]; then
    notify-send -u critical "Error" "Session file not found: $SESSION_FILE"
    echo "Session file not found: $SESSION_FILE"
    notify-send "Creating" "Creating new session file: $SESSION_FILE"
    echo "Creating new session file: $SESSION_FILE"
    touch "$SESSION_FILE"
fi

SESSION_NAME=$(
  awk -F ':' '{print $1}' "$SESSION_FILE" | 
  sort -u | 
  fzf --reverse \
      --info right \
      --prompt "Select a session: " \
      --border "rounded" \
      --border-label "WORK PROJECTS" \
      --preview "grep -e '^{}' $SESSION_FILE | column -t -s ':'" \
      --preview-window=right:65%
)

if [ -z "$SESSION_NAME" ]; then
    echo "No session selected."
    exit 1
fi

SESSION=$(grep "^$SESSION_NAME:" "$SESSION_FILE")

if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    tmux select-window -t "$SESSION_NAME:1"
    tmux attach-session -t "$SESSION_NAME"
    exit 0
fi

echo "$SESSION" | while IFS=: read -r session window window_name path command; do
    echo "Session: $session, Window: $window, Window Name: $window_name, Path: $path, Command: $command"
    
    tmux has-session -t "$session" 2>/dev/null || tmux new-session -d -s "$session"
    tmux new-window -t "$session:$window" 2>/dev/null
    tmux send-keys -t "$session:$window" "cd \"$path\" && $command" C-m
    tmux rename-window -t "$session:$window" "$window_name"
done

tmux select-window -t "$SESSION_NAME:1"
tmux attach-session -t "$SESSION_NAME"
