#!/bin/sh

server_names=`echo "sidouxp3 sidou fivation" | tr ' ' '\n'`
server_ips=("sidouxp3" "sidou" "fivation")

selected=`echo "$server_names"| cat -n | fzf --reverse --border "rounded" --border-label "SSH CONNECTION" --with-nth 2.. | awk '{print $1}'`

if [[ -z $selected ]]; then
    exit 0
fi

server=${server_ips[selected-1]}
ssh $server


