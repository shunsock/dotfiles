#!/bin/bash

# Spaces Plugin
# Highlights the active space

source "$HOME/.config/sketchybar/colors.sh"

if [ "$SELECTED" = "true" ]; then
  /opt/homebrew/opt/sketchybar/bin/sketchybar --set $NAME background.drawing=on \
                          background.color=$ACCENT_COLOR \
                          label.color=$WHITE \
                          icon.color=$WHITE
else
  /opt/homebrew/opt/sketchybar/bin/sketchybar --set $NAME background.drawing=on \
                          background.color=$ITEM_BG_COLOR \
                          label.color=$GREY \
                          icon.color=$GREY
fi
