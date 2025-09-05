#!/bin/sh

selected=$(cat ~/.ssh/config | grep -w Host| fzf --reverse --border "rounded" --border-label "SSH CONNECTION" --with-nth 2.. | awk -F ' ' '{print $2}')
if [ -z "$selected" ]; then
    exit 0
fi

SESSION_NAME="SSH_SERVERS"
RAW_NAME=$(echo "$selected" | tr '.' '_')
WINDOW_NAME="ssh_${RAW_NAME}"

# Create session if it doesn't exist
if ! tmux has-session -t "$SESSION_NAME ${RAW_NAME}" 2>/dev/null; then
    tmux new-session -d -s "$SESSION_NAME ${RAW_NAME}" -n "$WINDOW_NAME" "ssh $selected"
    tmux attach-session -t "$SESSION_NAME ${RAW_NAME}"
    exit 0
fi

# If window exists, switch to it
if tmux list-windows -t "$SESSION_NAME ${RAW_NAME}" | grep -q "^$WINDOW_NAME"; then
    tmux select-window -t "$SESSION_NAME ${RAW_NAME}:$WINDOW_NAME"
    tmux attach-session -t "$SESSION_NAME ${RAW_NAME}"
    exit 0
fi

# create a new window for the server if it doesn't exist
tmux new-window -t "$SESSION_NAME ${RAW_NAME}" -n "$WINDOW_NAME" "ssh $selected"
tmux select-window -t "$SESSION_NAME ${RAW_NAME}:$WINDOW_NAME"
tmux attach-session -t "$SESSION_NAME ${RAW_NAME}"
