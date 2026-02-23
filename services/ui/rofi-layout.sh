# --- Paths ---
STYLE_DIR="$HOME/.config/rofi/styles"
ASSET_DIR="$HOME/.config/rofi/assets"
THEME="$HOME/.config/rofi/selector.rasi"
LAYOUT_LINK="$HOME/.config/rofi/layout.rasi"
THUMB_OUT="$HOME/.config/rofi/bg.thmb"

# --- The "Worker" Function ---
generate_thumbnail() {
    wall="$1"
    style="$2"

    case "$style" in
        1|3|7|8)
            magick "$wall" -gravity center -crop 1:1 +repage -resize 800x800 "$THUMB_OUT" ;;
        9)
            magick "$wall" -gravity center -crop 16:10 +repage -resize 1200x "$THUMB_OUT" ;;
        *)
            magick "$wall" -gravity center -crop 16:9 +repage -resize 1000x "$THUMB_OUT" ;;
    esac
}

# --- Refresh Mode Check ---
if [ "${1:-}" = "--refresh" ]; then
    if [ -f "${2:-}" ] && [ -n "${3:-}" ]; then
        generate_thumbnail "$2" "$3"
        exit 0
    fi
fi

# --- Dependency Check ---
for cmd in rofi swww magick notify-send; do
    command -v "$cmd" >/dev/null 2>&1 || { notify-send "Rofi" "Missing: $cmd"; exit 1; }
done

# --- Get Current Wallpaper ---
WALLPAPER=$(swww query | awk -F'image: ' '/image:/ {print $2; exit}')

# --- Launch Rofi Selector ---
CHOICE=$(
    for file in "$STYLE_DIR"/style_*.rasi; do
        # Prevent errors if glob doesn't match any files
        [ -e "$file" ] || continue
        i=$(basename "$file" .rasi | cut -d'_' -f2)
        printf "%s\0icon\037%s\n" "$i" "$ASSET_DIR/style_${i}.png"
    done | rofi -dmenu -i -p "Select Layout" -theme "$THEME"
)

STYLE_NUM=$(printf '%s\n' "$CHOICE" | tr -d '[:space:]')
[ -z "$STYLE_NUM" ] && exit 0

# --- Apply & Generate ---
ln -sf "${STYLE_DIR}/style_${STYLE_NUM}.rasi" "$LAYOUT_LINK"
generate_thumbnail "$WALLPAPER" "$STYLE_NUM"

notify-send -i "$ASSET_DIR/style_${STYLE_NUM}.png" "Rofi" "Style ${STYLE_NUM} applied."