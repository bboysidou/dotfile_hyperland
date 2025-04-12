#!/bin/sh
new_session=$(echo "$1" | tr '[:upper:]' '[:lower:]')
check=$(awk -F ':' '{print tolower($1)}' saved_sessions.txt | sort | uniq | grep -w "$new_session")

if [ -z "$check" ]; then
  echo "$new_session" >> ~/.config/custom_scripts/tmux_sessions.txt 
  tmux new -s "$new_session"
else
  echo 'Session Exists'
fi
