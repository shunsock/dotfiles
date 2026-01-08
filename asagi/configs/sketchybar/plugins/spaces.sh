#!/bin/bash

# Spaces Plugin
# Highlights the active space

source "$HOME/.config/sketchybar/colors.sh"

if [ "$SELECTED" = "true" ]; then
  /opt/homebrew/opt/sketchybar/bin/sketchybar --set $NAME \
    background.drawing=on \
    background.color=$ACTIVE_ITEM_BG \
    background.corner_radius=5 \
    background.height=24 \
    label.color=$WHITE \
    icon.color=$WHITE
else
  /opt/homebrew/opt/sketchybar/bin/sketchybar --set $NAME \
    background.drawing=off \
    label.color=$GREY \
    icon.color=$GREY
fi
