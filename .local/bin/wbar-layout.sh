LAYOUT_DIR="$HOME/.config/waybar/layouts"
CONFIG_FILE="$HOME/.config/waybar/config.jsonc"
STYLE="$HOME/.config/waybar/style.css"

PICKED=$(ls "$LAYOUT_DIR"/*.jsonc | xargs -n 1 basename | sed 's/\.jsonc//' | rofi -dmenu -p "Select Layout" -theme ~/.config/rofi/styles/style_9.rasi)

[ -z "$PICKED" ] && exit 0

cat "$LAYOUT_DIR/$PICKED.jsonc" > "$CONFIG_FILE"

pkill waybar
waybar -c "$CONFIG_FILE" -s "$STYLE" > /dev/null 2>&1 &

notify-send "Waybar" "Layout $PICKED applied (Config Overwritten)."