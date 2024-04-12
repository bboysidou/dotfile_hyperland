#!/bin/sh

server_names=`echo "evo_production evo_gestion evo_net evo_auth isale_api isale_db femispace"|tr ' ' '\n'`
server_ips=("admineasy@185.243.215.222" "root@185.243.215.112" "root@185.96.163.193" "root@185.96.163.100" "root@194.32.79.85" "root@89.38.135.237" "root@93.115.21.152")

selected=`echo "$server_names"| cat -n | fzf --with-nth 2.. | awk '{print $1}'`

if [[ -z $selected ]]; then
    exit 0
fi

server=${server_ips[selected-1]}
ssh $server


