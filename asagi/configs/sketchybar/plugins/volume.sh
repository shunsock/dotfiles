#!/bin/bash

# Volume Plugin
# Shows system volume level

VOLUME=$(osascript -e "output volume of (get volume settings)")
MUTED=$(osascript -e "output muted of (get volume settings)")

if [[ $MUTED == "true" ]]; then
  ICON="󰖁"
  LABEL="Muted"
else
  if [ $VOLUME -gt 66 ]; then
    ICON="󰕾"
  elif [ $VOLUME -gt 33 ]; then
    ICON="󰖀"
  else
    ICON="󰕿"
  fi
  LABEL="${VOLUME}%"
fi

sketchybar --set $NAME icon="$ICON" label="$LABEL"
