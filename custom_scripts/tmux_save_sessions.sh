#!/bin/sh
tmux display-message "Saved sessions ...."
# tmux list-windows -a -F "#{session_name}:#{window_index}:#{window_name}:#{pane_id}:#{pane_current_path}:#{pane_current_command}" > ~/.config/custom_scripts/saved_sessions.txt
# tmux list-windows -a -F "#{session_name}:#{window_index}:#{window_name}:#{pane_id}:#{pane_current_path}:#{pane_current_command}" > ~/Downloads/dotfile_hyperland/tmux/saved_sessions.txt

# Path to the saved sessions file
SAVED_SESSIONS_FILE="$HOME/.config/custom_scripts/saved_sessions.txt"

# Temporary file to hold current tmux windows
TEMP_FILE=$(mktemp)

# List all tmux windows and save them to the temporary file
tmux list-windows -a -F "#{session_name}:#{window_index}:#{window_name}:#{pane_current_path}:#{pane_current_command}" > "$TEMP_FILE"

# Ensure the saved sessions file exists
touch "$SAVED_SESSIONS_FILE"

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
