#!/bin/sh

server_names=`echo "sidou evo_production evo_gestion femispace"|tr ' ' '\n'`
server_ips=("root@164.90.168.40" "evo@185.243.215.28 -p 1973" "evo_gestion" "root@93.115.21.152")

selected=`echo "$server_names"| cat -n | fzf --reverse --border "rounded" --border-label "SSH CONNECTION" --with-nth 2.. | awk '{print $1}'`

if [[ -z $selected ]]; then
    exit 0
fi

server=${server_ips[selected-1]}
ssh $server


