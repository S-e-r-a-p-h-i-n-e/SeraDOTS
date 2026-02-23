# 1. Catch the arguments
WALLPAPER="${1:-}"
WALLUST_CONFIG="${2:-$HOME/.config/wallust/wallust-dark.toml}"
KVANTUM_THEME="${3:-MateriaDark}"

# If no wallpaper given, query the current one
if [ -z "$WALLPAPER" ]; then
    WALLPAPER=$(swww query | awk -F'image: ' '/image:/ {print $2; exit}')
fi

# 2. Extract colors with Wallust
wallust run -C "$WALLUST_CONFIG" "$WALLPAPER"

# 3. Apply the Kvantum Theme (Modifies ~/.config/Kvantum/kvantum.kvconfig)
kvantummanager --set "$KVANTUM_THEME"

# 4. Update the Rofi layout / thumbnail
CURRENT_STYLE=$(readlink "$HOME/.config/rofi/layout.rasi" | sed 's/.*style_\([0-9]*\).rasi/\1/')
bash "$HOME/.config/YASD/scripts/rofi-layout.sh" --refresh "$WALLPAPER" "$CURRENT_STYLE"

# 5. Reload desktop components
swaymsg reload
killall -SIGUSR2 waybar
swaync-client -R && swaync-client -rs
kill -SIGUSR1 $(pgrep -u $USER kitty)
kitty -e spicetify apply

# 6. Notify
notify-send -i "$WALLPAPER" "System Synced" "Config: $(basename "$WALLUST_CONFIG")"
