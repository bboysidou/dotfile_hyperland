#!/bin/sh
tmux display-message "Reloading config ...."

tmux source-file ~/.config/tmux/tmux.conf

tmux display-message "Config reloaded Successfully"
