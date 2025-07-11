#!/bin/bash
eval $(gnome-keyring-daemon --start --components=pkcs11,secrets,ssh)
echo "set -gx SSH_AUTH_SOCK $SSH_AUTH_SOCK" > "$XDG_RUNTIME_DIR/keyring.fish"
