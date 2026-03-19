#!/bin/sh
set -eu

# --- Paths ---
WALL_DIR="$HOME/.config/SeraDOTS/wallpapers"
THEME="$HOME/.config/rofi/wallpaper.rasi"
SNAP_DIR="/tmp/wallchange_snaps"

WALLUST_LIGHT="$HOME/.config/wallust/wallust-light.toml"
WALLUST_DARK="$HOME/.config/wallust/wallust-dark.toml"

# --- Ensure Wayland env is set ---
export WAYLAND_DISPLAY="${WAYLAND_DISPLAY:-wayland-1}"

# --- Dependency check ---
for cmd in swww rofi notify-send magick bc ffmpeg mpvpaper; do
    command -v "$cmd" >/dev/null 2>&1 || {
        notify-send "Wallpaper Selector Error" "Missing dependency: $cmd"
        exit 1
    }
done

mkdir -p "$SNAP_DIR"

# --- Helpers ---
is_video() {
    case "${1##*.}" in
        mp4|webm|mkv|mov|avi) return 0 ;;
        *) return 1 ;;
    esac
}

# Get or create a cached snapshot for a video.
get_snap() {
    VIDEO="$1"
    NAME="${VIDEO##*/}"
    OUT="$SNAP_DIR/${NAME}.jpg"
    if [ ! -f "$OUT" ]; then
        ffmpeg -ss 5 -i "$VIDEO" -frames:v 1 -q:v 2 "$OUT" -y >/dev/null 2>&1 || \
        ffmpeg        -i "$VIDEO" -frames:v 1 -q:v 2 "$OUT" -y >/dev/null 2>&1 || \
        return 1
    fi
    printf '%s' "$OUT"
}

# --- Build file list and Rofi Menu ---
# Store full paths in a temp file so we can look them up after rofi returns
# a bare filename. find -name uses glob matching which breaks on filenames
# containing [ ] characters — we avoid that entirely by storing the full list.
FILE_LIST=$(mktemp)
trap 'rm -f "$FILE_LIST"' EXIT

find "$WALL_DIR" -type f \( \
    -iname "*.jpg"  -o -iname "*.jpeg" -o \
    -iname "*.png"  -o -iname "*.webp" -o \
    -iname "*.mp4"  -o -iname "*.webm" -o \
    -iname "*.mkv"  -o -iname "*.mov"  -o \
    -iname "*.avi" \
\) > "$FILE_LIST"

CHOICE=$(while IFS= read -r img; do
    name="${img##*/}"
    if is_video "$img"; then
        snap=$(get_snap "$img" 2>/dev/null) || snap=""
        if [ -n "$snap" ]; then
            printf '%s\0icon\037%s\n' "$name" "$snap"
        else
            printf '%s\n' "$name"
        fi
    else
        printf '%s\0icon\037%s\n' "$name" "$img"
    fi
done < "$FILE_LIST" | rofi -dmenu -i -p "Select Wallpaper" -theme "$THEME" -show-icons)

[ -z "$CHOICE" ] && exit 0

# Resolve full path using fixed-string grep on the stored list
# This avoids find -name glob interpretation of [ ] in filenames
FULL_PATH=$(grep -F "/$CHOICE" "$FILE_LIST" | head -n 1)

[ -z "$FULL_PATH" ] && exit 0

# --- Apply wallpaper ---
if is_video "$FULL_PATH"; then
    pkill -x mpvpaper    2>/dev/null || true
    pkill -x swww-daemon 2>/dev/null || true
    sleep 0.5

    # Detect connected monitor name — mpvpaper requires the actual output name
    MONITOR=""
    if command -v hyprctl >/dev/null 2>&1; then
        MONITOR=$(hyprctl monitors -j 2>/dev/null | \
            grep -m1 '"name"' | sed 's/.*"name": *"\([^"]*\)".*/\1/')
    fi
    if [ -z "$MONITOR" ]; then
        MONITOR=$(find /sys/class/drm -name status 2>/dev/null \
            | xargs grep -l '^connected$' 2>/dev/null \
            | head -n 1 \
            | xargs dirname 2>/dev/null \
            | xargs basename 2>/dev/null \
            | sed 's/card[0-9]*-//')
    fi
    if [ -z "$MONITOR" ]; then
        notify-send "Wallpaper Error" "Could not detect monitor name for mpvpaper"
        exit 1
    fi

    mpvpaper -f -o "no-audio loop" "$MONITOR" "$FULL_PATH"

    SAMPLE=$(get_snap "$FULL_PATH") || {
        notify-send "Wallpaper Applied" "Video set — snapshot unavailable, theme not synced"
        exit 0
    }
else
    pkill -x mpvpaper 2>/dev/null || true
    pgrep -x swww-daemon >/dev/null 2>&1 || { swww-daemon & sleep 0.5; }
    swww img "$FULL_PATH" --transition-type grow --transition-pos 0.5,0.5 --transition-step 90
    SAMPLE="$FULL_PATH"
fi

# --- Brightness detection ---
BRIGHTNESS=$(magick "$SAMPLE" -colorspace Gray -format "%[fx:100*median]" info:)

IS_LIGHT=$(echo "$BRIGHTNESS > 60" | bc -l)

if [ "$IS_LIGHT" = "1" ]; then
    WALLUST_CONFIG="$WALLUST_LIGHT"
    KVANTUM_THEME="MateriaLight"
    MODE_MSG="Light Mode"
else
    WALLUST_CONFIG="$WALLUST_DARK"
    KVANTUM_THEME="MateriaDark"
    MODE_MSG="Dark Mode"
fi

# --- Theme sync ---
# For videos, pass the snapshot to theme-sync so wallust gets a valid image.
# The notify icon uses the snapshot too since the video path isn't a valid image.
if command -v theme-sync.sh >/dev/null 2>&1; then
    theme-sync.sh "$SAMPLE" "$WALLUST_CONFIG" "$KVANTUM_THEME"
    BRIGHTNESS_INT=${BRIGHTNESS%.*}
    notify-send "Wallpaper Applied" "Detected $MODE_MSG (Brightness: ${BRIGHTNESS_INT}%)"
else
    notify-send "Wallpaper Selector Warning" "theme-sync command not found in PATH"
fi
