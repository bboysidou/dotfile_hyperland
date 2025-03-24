#!/bin/sh

APP_NAME="$1"
MSG_BODY="$2"

BROWSERS=("firefox" "brave" "chromium" "google-chrome")

for browser in "${BROWSERS[@]}"; do
    if [[ "$APP_NAME" == *"$browser"* ]]; then
        BROWSER_FOUND=true
        break
    fi
done

if [[ -z "$BROWSER_FOUND" ]]; then
    exit 0 
fi

ACTIVE_TAB=$(echo "$MSG_BODY" | grep -Eo 'https?://[^ ]+')

if [[ -z "$ACTIVE_TAB" ]]; then
    exit 0
fi

DOMAIN=$(echo "$ACTIVE_TAB" | awk -F/ '{print $3}')

FAVICON_URL="https://icons.duckduckgo.com/ip2/$DOMAIN.ico"
ICON_PATH="/tmp/${DOMAIN}.png"

curl -s "$FAVICON_URL" -o "$ICON_PATH"

notify-send -i "$ICON_PATH" "$APP_NAME" "$MSG_BODY"
