#!/bin/bash
set -euo pipefail

# --- Paths ---
WALL_DIR="$HOME/.config/YASD/wallpapers"
THEME="$HOME/.config/rofi/selector.rasi"
SYNC_SCRIPT="$HOME/.config/YASD/scripts/theme-sync.sh"

# TOML configs
WALLUST_LIGHT="$HOME/.config/wallust/wallust-light.toml"
WALLUST_DARK="$HOME/.config/wallust/wallust-dark.toml"

# --- Dependency Check ---
for cmd in swww rofi notify-send magick bc; do
    command -v "$cmd" >/dev/null 2>&1 || {
        notify-send "Wallpaper Selector Error" "Missing dependency: $cmd"
        exit 1
    }
done

# --- Build Wallpaper List ---
declare -A WALLPAPERS
MENU_LIST=""

while IFS= read -r -d '' img; do
    name=$(basename "$img")
    WALLPAPERS["$name"]="$img"
    MENU_LIST+="$name\0icon\x1f$img\n"
done < <(find "$WALL_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" -o -iname "*.webp" \) -print0)

# Launch Rofi
CHOICE=$(printf "%b" "$MENU_LIST" | rofi -dmenu -i -p "Select Wallpaper" -theme "$THEME" -show-icons)

# --- Apply Wallpaper ---
if [ -n "$CHOICE" ] && [[ -n "${WALLPAPERS[$CHOICE]:-}" ]]; then
    FULL_PATH="${WALLPAPERS[$CHOICE]}"

    # Set the wallpaper
    swww img "$FULL_PATH" --transition-type grow --transition-pos 0.5,0.5 --transition-step 90

    # Detect brightness (0-100)
    BRIGHTNESS=$(magick "$FULL_PATH" -colorspace Gray -format "%[fx:100*mean]" info:)

    # Choose Wallust TOML based on brightness
    if (( $(echo "$BRIGHTNESS > 60" | bc -l) )); then
        WALLUST_CONFIG="$WALLUST_LIGHT"
        MODE_MSG="Light Mode"
    else
        WALLUST_CONFIG="$WALLUST_DARK"
        MODE_MSG="Dark Mode"
    fi

    # Run the sync script with the selected TOML
    if [ -f "$SYNC_SCRIPT" ]; then
        bash "$SYNC_SCRIPT" "$FULL_PATH" "$WALLUST_CONFIG"
        notify-send -i "$FULL_PATH" "Wallpaper Applied" "Detected $MODE_MSG (Brightness: ${BRIGHTNESS%.*}%)"
    else
        notify-send "Wallpaper Selector Warning" "theme-sync.sh not found at $SYNC_SCRIPT"
    fi
fi
