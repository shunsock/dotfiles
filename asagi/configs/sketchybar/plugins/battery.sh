#!/bin/bash

# Battery Plugin
# Shows battery percentage and status

PERCENTAGE=$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)
CHARGING=$(pmset -g batt | grep 'AC Power')

if [ $PERCENTAGE = "" ]; then
  exit 0
fi

# Determine icon based on charging status and percentage
if [[ $CHARGING != "" ]]; then
  ICON="󰂄"
else
  if [ $PERCENTAGE -gt 80 ]; then
    ICON="󰁹"
  elif [ $PERCENTAGE -gt 60 ]; then
    ICON="󰂀"
  elif [ $PERCENTAGE -gt 40 ]; then
    ICON="󰁾"
  elif [ $PERCENTAGE -gt 20 ]; then
    ICON="󰁼"
  else
    ICON="󰁺"
  fi
fi

sketchybar --set $NAME icon="$ICON" label="${PERCENTAGE}"
