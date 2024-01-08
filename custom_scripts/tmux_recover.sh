#!/bin/sh
selected=$(cat ~/.config/custom_scripts/tmux_sessions.txt | fzf)
if [[ -z $selected ]]; then
    exit 0
fi
check=$(tmux ls |grep $selected)

echo "${check}"

if [ -z "$check" ]; then
    tmux new -s $selected
else
    tmux attach -t $selected
fi

