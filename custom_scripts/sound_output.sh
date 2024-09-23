#!/bin/sh

selected=$(pactl list short sinks | cut -f 2 | fzf --reverse --border "rounded" --border-label "SOUND OUTPUT")
pactl set-default-sink $selected
