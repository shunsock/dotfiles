#!/bin/bash

PERCENTAGE=$1

if [[ ! "$PERCENTAGE" =~ ^[0-9]+$ ]] || [ "$PERCENTAGE" -lt 0 ] || [ "$PERCENTAGE" -gt 100 ]; then
  exit 1
fi

osascript -e "set volume output volume $PERCENTAGE"
bash "$HOME/.config/sketchybar/plugins/volume.sh"
