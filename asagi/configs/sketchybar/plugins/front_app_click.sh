#!/bin/bash

SKETCHYBAR="/opt/homebrew/opt/sketchybar/bin/sketchybar"

# Get current app name
APP_NAME=$(osascript -e 'tell application "System Events" to get name of first application process whose frontmost is true')

# Check if popup items exist
POPUP_EXISTS=$($SKETCHYBAR --query app.hide 2>/dev/null)

if [ -z "$POPUP_EXISTS" ]; then
  # Create popup menu items
  $SKETCHYBAR --add item app.hide popup.front_app \
              --set app.hide label="Hide $APP_NAME" \
                             click_script="osascript -e 'tell application \"$APP_NAME\" to set visible to false'; $SKETCHYBAR --set front_app popup.drawing=off" \
              \
              --add item app.quit popup.front_app \
              --set app.quit label="Quit $APP_NAME" \
                            click_script="osascript -e 'tell application \"$APP_NAME\" to quit'; $SKETCHYBAR --set front_app popup.drawing=off" \
              \
              --add item app.force_quit popup.front_app \
              --set app.force_quit label="Force Quit..." \
                                  click_script="open -a 'Activity Monitor'; $SKETCHYBAR --set front_app popup.drawing=off"
else
  # Update labels with current app name
  $SKETCHYBAR --set app.hide label="Hide $APP_NAME" \
                             click_script="osascript -e 'tell application \"$APP_NAME\" to set visible to false'; $SKETCHYBAR --set front_app popup.drawing=off" \
              --set app.quit label="Quit $APP_NAME" \
                            click_script="osascript -e 'tell application \"$APP_NAME\" to quit'; $SKETCHYBAR --set front_app popup.drawing=off"
fi

# Toggle popup
$SKETCHYBAR --set front_app popup.drawing=toggle
