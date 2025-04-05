#!/bin/sh

# Temp file
IMG="/tmp/ocr.png"

# Capture region and save image
grim -g "$(slurp)" "$IMG"

# OCR the image
text=$(tesseract "$IMG" - -l eng 2>/dev/null)

# Copy to clipboard (wl-copy is Wayland-friendly)
echo "$text" | wl-copy
rm "$IMG"
echo "$text"
# Notify user
notify-send "OCR Complete" "$text"
