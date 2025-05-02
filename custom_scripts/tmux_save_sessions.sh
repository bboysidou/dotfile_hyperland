#!/bin/sh
tmux display-message "Saving sessions ...."

SAVED_SESSIONS_FILE="$HOME/.config/custom_scripts/saved_sessions.txt"

TEMP_FILE=$(mktemp)

tmux list-windows -a -F "#{session_name}:#{window_index}:#{window_name}:#{pane_current_path}:#{pane_current_command}" > "$TEMP_FILE"

if [ ! -f "$SAVED_SESSIONS_FILE" ]; then
    echo "Session file not found: $SAVED_SESSIONS_FILE"
    echo "Creating new session file: $SAVED_SESSIONS_FILE"
    touch "$SAVED_SESSIONS_FILE"
fi

while read -r line; do
    if ! grep -Fxq "$line" "$SAVED_SESSIONS_FILE"; then
        echo "$line" >> "$SAVED_SESSIONS_FILE"
    fi
done < "$TEMP_FILE"

rm "$TEMP_FILE"
tmux display-message "Sessions saved Successfully"
