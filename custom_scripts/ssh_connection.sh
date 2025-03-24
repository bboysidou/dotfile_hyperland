#!/bin/sh

server_names=`echo "sidouxp3 sidou fivation sifartek" | tr ' ' '\n'`
server_ips=("sidouxp3" "sidou" "fivation" "sifartek")

selected=`echo "$server_names"| cat -n | fzf --reverse --border "rounded" --border-label "SSH CONNECTION" --with-nth 2.. | awk '{print $1}'`

if [[ -z $selected ]]; then
    exit 0
fi

server=${server_ips[selected-1]}
SESSION_NAME="ssh_$(echo "$server" | tr '.' '_')"

if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    tmux attach-session -t "$SESSION_NAME"
else
    tmux new-session -s "$SESSION_NAME" "ssh $server"
fi
