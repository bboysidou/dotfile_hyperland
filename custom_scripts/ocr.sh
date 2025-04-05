#!/bin/sh

grim -g "$(slurp)" /tmp/ocr.png && tesseract /tmp/ocr.png -
