#!/bin/bash

# 1. Catch the wallpaper and Wallust config
WALLPAPER="${1:-}"
WALLUST_CONFIG="${2:-$HOME/.config/wallust/wallust-dark.toml}"  # default to dark if not passed

# If no wallpaper given, query the current one
if [ -z "$WALLPAPER" ]; then
    WALLPAPER=$(swww query | awk -F'image: ' '/image:/ {print $2; exit}')
fi

# 2. Extract colors with Wallust using the selected config
wallust run -C "$WALLUST_CONFIG" "$WALLPAPER"

# 3. Update the Rofi layout / thumbnail
CURRENT_STYLE=$(readlink "$HOME/.config/rofi/layout.rasi" | sed 's/.*style_\([0-9]*\).rasi/\1/')
bash "$HOME/.config/YASD/scripts/rofi-layout.sh" --refresh "$WALLPAPER" "$CURRENT_STYLE"

# 4. Reload desktop components
swaymsg reload
killall -SIGUSR2 waybar
swaync-client -R && swaync-client -rs
kill -SIGUSR1 $(pgrep -u $USER kitty)
kitty -e spicetify apply

# 5. Notify
notify-send -i "$WALLPAPER" "System Synced" "Config: $(basename "$WALLUST_CONFIG")"
