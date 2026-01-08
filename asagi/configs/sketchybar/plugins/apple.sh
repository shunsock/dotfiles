#!/bin/bash

SKETCHYBAR="/opt/homebrew/opt/sketchybar/bin/sketchybar"
source "$HOME/.config/sketchybar/colors.sh"

# Check if popup items already exist
POPUP_EXISTS=$($SKETCHYBAR --query apple.about 2>/dev/null)

if [ -z "$POPUP_EXISTS" ]; then
  # Create popup menu items (only once)
  $SKETCHYBAR --add item apple.about popup.apple.logo \
              --set apple.about label="About This Mac" \
                                click_script="open -a 'System Settings'; $SKETCHYBAR --set apple.logo popup.drawing=off" \
              \
              --add item apple.preferences popup.apple.logo \
              --set apple.preferences label="System Settings..." \
                                     click_script="open -a 'System Settings'; $SKETCHYBAR --set apple.logo popup.drawing=off" \
              \
              --add item apple.activity popup.apple.logo \
              --set apple.activity label="Activity Monitor" \
                                  click_script="open -a 'Activity Monitor'; $SKETCHYBAR --set apple.logo popup.drawing=off" \
              \
              --add item apple.lock popup.apple.logo \
              --set apple.lock label="Lock Screen" \
                              click_script="pmset displaysleepnow; $SKETCHYBAR --set apple.logo popup.drawing=off" \
              \
              --add item apple.sleep popup.apple.logo \
              --set apple.sleep label="Sleep" \
                               click_script="pmset sleepnow; $SKETCHYBAR --set apple.logo popup.drawing=off"
fi

# Toggle popup visibility
$SKETCHYBAR --set apple.logo popup.drawing=toggle
