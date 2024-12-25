#!/bin/sh
selected=$(cat ~/.config/custom_scripts/tmux_sessions.txt | fzf --reverse --border "rounded" --border-label "WORK PROJECTS")
if [[ -z $selected ]]; then
    exit 0
fi
check=$(tmux ls |grep $selected)

echo "${check}"

tmux_running=$(pgrep tmux)

if [[ -z $TMUX ]] && [[ -z $tmux_running ]]; then
    tmux new-session -s $selected -c $selected
    exit 0
fi

if ! tmux has-session -t=$selected 2> /dev/null; then
    tmux new-session -ds $selected -c $selected
fi

# tmux switch-client -t $selected
tmux attach -t $selected

# if [ -z "$check" ]; then
#     tmux new -s $selected
# else
#     tmux attach -t $selected
# fi

