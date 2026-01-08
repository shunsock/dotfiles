#!/bin/bash

# Volume Plugin
# Shows system volume level with interactive slider and popup

SKETCHYBAR="/opt/homebrew/opt/sketchybar/bin/sketchybar"
VOLUME=$(osascript -e "output volume of (get volume settings)")
MUTED=$(osascript -e "output muted of (get volume settings)")

# Determine icon based on volume level and mute status
if [[ $MUTED == "true" ]]; then
  ICON="󰝟"
  LABEL="Muted"
else
  if [ $VOLUME -gt 66 ]; then
    ICON="󰕾"
  elif [ $VOLUME -gt 33 ]; then
    ICON="󰖀"
  elif [ $VOLUME -gt 0 ]; then
    ICON="󰕿"
  else
    ICON="󰸈"
  fi
  LABEL="${VOLUME}%"
fi

# Update main volume item
$SKETCHYBAR --set $NAME icon="$ICON" label="$LABEL"

# Update slider if it exists
if $SKETCHYBAR --query volume_slider &>/dev/null; then
  $SKETCHYBAR --set volume_slider slider.percentage=$VOLUME
fi

# Show volume popup temporarily when volume changes
$SKETCHYBAR --set volume_popup drawing=on \
            --set volume_popup icon="$ICON" \
            --set volume_popup label="$LABEL" \
            --animate sin 15 \
            --set volume_popup label.y_offset=0 \
            icon.y_offset=0

# Hide popup after 2 seconds
(sleep 2 && $SKETCHYBAR --set volume_popup drawing=off) &
