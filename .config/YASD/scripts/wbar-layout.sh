#!/bin/bash

# --- Paths ---
LAYOUT_DIR="$HOME/.config/waybar/layouts"
CONFIG_FILE="$HOME/.config/waybar/config.jsonc"
STYLE="$HOME/.config/waybar/style.css"

# --- Pick Layout ---
PICKED=$(ls "$LAYOUT_DIR"/*.jsonc | xargs -n 1 basename | sed 's/\.jsonc//' | rofi -dmenu -p "Select Layout" -theme ~/.config/rofi/styles/style_9.rasi)

# Exit if nothing was picked
[ -z "$PICKED" ] && exit 0

# --- Apply & Restart ---
# 1. Overwrite the current config with the chosen layout
# We re-add the full path and .jsonc extension here
cat "$LAYOUT_DIR/$PICKED.jsonc" > "$CONFIG_FILE"

# 2. Kill and Restart Waybar
pkill waybar
waybar -c "$CONFIG_FILE" -s "$STYLE" > /dev/null 2>&1 &

# 3. Notification
notify-send "Waybar" "Layout $PICKED applied (Config Overwritten)."