#!/bin/sh

# PUT YOUR SERVER NAME BETWEEN THE DOUBLE QUOTES AND SEPARATE THEM WITH SPACE
server_names=`echo "SERVER01 SERVER02"|tr ' ' '\n'`

# PUT YOUR SERVER CONNECTION HERE AND SEPARATE THEM WITH SPACE
server_ips=("user@ip" "user@ip")

selected=`echo "$server_names"| cat -n | fzf --with-nth 2.. | awk '{print $1}'`

server=${server_ips[selected-1]}

ssh $server


