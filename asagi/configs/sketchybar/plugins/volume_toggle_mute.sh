#!/bin/bash

MUTED=$(osascript -e "output muted of (get volume settings)")

if [[ $MUTED == "true" ]]; then
  osascript -e "set volume output muted false"
else
  osascript -e "set volume output muted true"
fi

# Update display
$HOME/.config/sketchybar/plugins/volume.sh
