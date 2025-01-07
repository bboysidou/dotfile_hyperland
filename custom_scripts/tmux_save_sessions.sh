#!/bin/sh
tmux display-message "Saving sessions ...."

# Path to the saved sessions file
SAVED_SESSIONS_FILE="$HOME/.config/custom_scripts/saved_sessions.txt"

# Temporary file to hold current tmux windows
TEMP_FILE=$(mktemp)

# List all tmux windows and save them to the temporary file
tmux list-windows -a -F "#{session_name}:#{window_index}:#{window_name}:#{pane_current_path}:#{pane_current_command}" > "$TEMP_FILE"

# Ensure the saved sessions file exists
if [ ! -f "$SAVED_SESSIONS_FILE" ]; then
    echo "Session file not found: $SAVED_SESSIONS_FILE"
    echo "Creating new session file: $SAVED_SESSIONS_FILE"
    touch "$SAVED_SESSIONS_FILE"
fi

# Append unique entries to the saved sessions file
while read -r line; do
    # Check if the line already exists in the saved sessions file
    if ! grep -Fxq "$line" "$SAVED_SESSIONS_FILE"; then
        echo "$line" >> "$SAVED_SESSIONS_FILE"
    fi
done < "$TEMP_FILE"

# Remove the temporary file
rm "$TEMP_FILE"
tmux display-message "Sessions saved Successfully"
