#!/bin/sh

server_names=$(echo "sidouxp3 sidou fivation sifartek" | tr ' ' '\n')
server_ips=("sidouxp3" "sidou" "fivation" "sifartek")

selected=$(echo "$server_names" | cat -n | fzf --reverse --border "rounded" --border-label "SSH CONNECTION" --with-nth 2.. | awk '{print $1}')

if [ -z "$selected" ]; then
    exit 0
fi

server=${server_ips[selected-1]}
SESSION_NAME="SSH_SERVERS"
RAW_NAME=$(echo "$server" | tr '.' '_')
WINDOW_NAME="ssh_${RAW_NAME}"

# Create session if it doesn't exist
if ! tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    tmux new-session -d -s "$SESSION_NAME" -n "$WINDOW_NAME" "ssh $server"
    tmux attach-session -t "$SESSION_NAME"
    exit 0
fi

# If window exists, switch to it
if tmux list-windows -t "$SESSION_NAME" | grep -q "^$WINDOW_NAME"; then
    tmux select-window -t "$SESSION_NAME:$WINDOW_NAME"
    tmux attach-session -t "$SESSION_NAME"
    exit 0
fi

# create a new window for the server if it doesn't exist
tmux new-window -t "$SESSION_NAME" -n "$WINDOW_NAME" "ssh $server"
tmux select-window -t "$SESSION_NAME:$WINDOW_NAME"
tmux attach-session -t "$SESSION_NAME"
