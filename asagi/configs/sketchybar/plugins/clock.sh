#!/bin/bash

# Clock Plugin
# Shows current date and time in ISO 8601 format

# Format: YYYY-MM-DD HH:MM (e.g., 2026-01-08 14:17)
DATETIME=$(date '+%Y-%m-%d %H:%M')

/opt/homebrew/opt/sketchybar/bin/sketchybar --set $NAME icon="" label="$DATETIME"
