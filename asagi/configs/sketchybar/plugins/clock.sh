#!/bin/bash

# Clock Plugin
# Shows current date and time

# Format: Sun 08. Jan 14:17
DATETIME=$(date '+%a %d. %b %H:%M')

/opt/homebrew/opt/sketchybar/bin/sketchybar --set $NAME label="$DATETIME"
