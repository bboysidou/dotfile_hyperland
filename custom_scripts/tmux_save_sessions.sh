#!/bin/sh
set -u

FILE="$HOME/.config/custom_scripts/saved_sessions.txt"

IGNORE_SESSIONS='^(scratch|tmp|popup)$'
KEEP_COMMANDS='^(nvim|vim|nano|lazygit|lazydocker|htop|btop|top|yazi|ranger)$'

SNAP=$(mktemp) || exit 1
FILTERED=$(mktemp) || exit 1
MERGED=$(mktemp "$FILE.XXXXXX") || exit 1
trap 'rm -f "$SNAP" "$FILTERED" "$MERGED"' EXIT INT TERM

tmux display-message "Saving sessions ..."

if ! touch "$FILE" 2>/dev/null; then
    tmux display-message "save failed: cannot write $FILE"
    exit 1
fi

if ! tmux list-windows -a -F '#{session_name}:#{window_index}:#{window_name}:#{pane_current_path}:#{pane_current_command}' >"$SNAP"; then
    tmux display-message "save failed: cannot read tmux state"
    exit 1
fi

awk -F: -v OFS=: -v ign="$IGNORE_SESSIONS" -v keep="$KEEP_COMMANDS" '
    $1 ~ ign { next }
    $NF !~ keep { $NF = "" }
    { print }
' "$SNAP" >"$FILTERED"

LIVE=$(cut -d: -f1 "$FILTERED" | sort -u | paste -sd'|' -)

if [ -z "$LIVE" ]; then
    tmux display-message "nothing to save"
    exit 0
fi

cp "$FILE" "$FILE.bak"

grep -vE "^($LIVE):" "$FILE" >"$MERGED" || true
cat "$FILTERED" >>"$MERGED"

chmod --reference="$FILE" "$MERGED"
mv "$MERGED" "$FILE"

tmux display-message "Saved $(wc -l <"$FILTERED" | tr -d ' ') windows across $(echo "$LIVE" | tr '|' '\n' | wc -l | tr -d ' ') sessions"
