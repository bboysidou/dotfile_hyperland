#!/bin/bash
eval $(gnome-keyring-daemon --start --components=pkcs11,secrets)
echo "set -gx SSH_AUTH_SOCK $XDG_RUNTIME_DIR/gcr/ssh" > "$XDG_RUNTIME_DIR/keyring.fish"
