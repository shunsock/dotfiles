#!/bin/bash

# Front App Plugin
# Shows the currently focused application with icon

source "$HOME/.config/sketchybar/colors.sh"

SKETCHYBAR="/opt/homebrew/opt/sketchybar/bin/sketchybar"

# Get the current application name
APP_NAME="$INFO"

if [ -z "$APP_NAME" ]; then
  APP_NAME="Finder"
fi

# Map common applications to Nerd Font icons
case "$APP_NAME" in
  "WezTerm")
    ICON=""
    ;;
  "Arc")
    ICON=""
    ;;
  "Safari")
    ICON=""
    ;;
  "Visual Studio Code"|"Code")
    ICON="󰨞"
    ;;
  "Terminal")
    ICON=""
    ;;
  "Finder")
    ICON=""
    ;;
  "Mail")
    ICON=""
    ;;
  "Calendar")
    ICON=""
    ;;
  "Music")
    ICON=""
    ;;
  "Notes")
    ICON=""
    ;;
  "Slack")
    ICON="󰒱"
    ;;
  "Discord")
    ICON="󰙯"
    ;;
  "Chrome"|"Google Chrome")
    ICON=""
    ;;
  "Firefox")
    ICON=""
    ;;
  "Messages")
    ICON="󰍡"
    ;;
  "System Settings"|"System Preferences")
    ICON=""
    ;;
  *)
    ICON=""  # Default icon for unknown apps
    ;;
esac

$SKETCHYBAR --set $NAME icon="$ICON" label="$APP_NAME"
