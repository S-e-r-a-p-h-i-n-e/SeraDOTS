set -eu

# --- Paths ---
WALL_DIR="$HOME/.config/YASD/wallpapers"
THEME="$HOME/.config/rofi/selector.rasi"
SYNC_SCRIPT="$HOME/.config/YASD/scripts/theme-sync.sh"

WALLUST_LIGHT="$HOME/.config/wallust/wallust-light.toml"
WALLUST_DARK="$HOME/.config/wallust/wallust-dark.toml"

for cmd in swww rofi notify-send magick bc; do
    command -v "$cmd" >/dev/null 2>&1 || {
        notify-send "Wallpaper Selector Error" "Missing dependency: $cmd"
        exit 1
    }
done

# --- Build & Display Rofi Menu (No Arrays Used) ---
CHOICE=$(find "$WALL_DIR" -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.jpeg" -o -name "*.webp" \) | while IFS= read -r img; do
    name=${img##*/}
    # \037 is POSIX octal for unit separator (Rofi's \x1f)
    printf '%s\0icon\037%s\n' "$name" "$img"
done | rofi -dmenu -i -p "Select Wallpaper" -theme "$THEME" -show-icons)

# --- Apply Wallpaper ---
if [ -n "$CHOICE" ]; then
    # Grab the exact path again since we aren't caching it in memory
    FULL_PATH=$(find "$WALL_DIR" -type f -name "$CHOICE" | head -n 1)

    if [ -n "$FULL_PATH" ]; then
        swww img "$FULL_PATH" --transition-type grow --transition-pos 0.5,0.5 --transition-step 90

        BRIGHTNESS=$(magick "$FULL_PATH" -colorspace Gray -format "%[fx:100*mean]" info:)

        # bc returns 1 for true, 0 for false
        IS_LIGHT=$(echo "$BRIGHTNESS > 60" | bc -l)

        if [ "$IS_LIGHT" = "1" ]; then
            WALLUST_CONFIG="$WALLUST_LIGHT"
            MODE_MSG="Light Mode"
        else
            WALLUST_CONFIG="$WALLUST_DARK"
            MODE_MSG="Dark Mode"
        fi

        if [ -f "$SYNC_SCRIPT" ]; then
            sh "$SYNC_SCRIPT" "$FULL_PATH" "$WALLUST_CONFIG"
            
            # Remove decimal for clean display
            BRIGHTNESS_INT=${BRIGHTNESS%.*}
            notify-send -i "$FULL_PATH" "Wallpaper Applied" "Detected $MODE_MSG (Brightness: ${BRIGHTNESS_INT}%)"
        else
            notify-send "Wallpaper Selector Warning" "theme-sync.sh not found at $SYNC_SCRIPT"
        fi
    fi
fi