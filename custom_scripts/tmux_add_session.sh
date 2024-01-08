#!/bin/sh
new_session=$1
check=$(cat ~/.config/custom_scripts/tmux_sessions.txt |grep -w $new_session)

if [ -z "$check" ]; then
 echo $new_session >>  ~/.config/custom_scripts/tmux_sessions.txt 
 tmux new -s $new_session
else
  echo 'Session Exists'
fi
