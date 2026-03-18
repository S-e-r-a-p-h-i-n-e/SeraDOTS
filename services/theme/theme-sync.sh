#!/bin/sh
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

# 4. Handle GTK Light/Dark Switching (Adwaita Native)
if [ "$KVANTUM_THEME" = "MateriaLight" ]; then
    GTK_THEME="Materia-light"
    GTK_DARK="0"
    COLOR_SCHEME="prefer-light"
else
    GTK_THEME="Materia-dark"
    GTK_DARK="1"
    COLOR_SCHEME="prefer-dark"
fi

# Edit GTK3 & GTK4 settings.ini strictly via files
if [ -f "$HOME/.config/gtk-3.0/settings.ini" ]; then
    sed -i "s/^gtk-theme-name=.*/gtk-theme-name=$GTK_THEME/" "$HOME/.config/gtk-3.0/settings.ini"
    sed -i "s/^gtk-application-prefer-dark-theme=.*/gtk-application-prefer-dark-theme=$GTK_DARK/" "$HOME/.config/gtk-3.0/settings.ini"
fi

if [ -f "$HOME/.config/gtk-4.0/settings.ini" ]; then
    sed -i "s/^gtk-theme-name=.*/gtk-theme-name=$GTK_THEME/" "$HOME/.config/gtk-4.0/settings.ini"
    sed -i "s/^gtk-application-prefer-dark-theme=.*/gtk-application-prefer-dark-theme=$GTK_DARK/" "$HOME/.config/gtk-4.0/settings.ini"
fi

# Live Reload via gsettings (Critical for GTK4/Libadwaita apps like Nautilus)
if command -v gsettings >/dev/null 2>&1; then
    gsettings set org.gnome.desktop.interface gtk-theme "$GTK_THEME"
    gsettings set org.gnome.desktop.interface color-scheme "$COLOR_SCHEME"
fi

# 5. Update the Rofi layout / thumbnail
CURRENT_STYLE=$(readlink "$HOME/.config/rofi/layout.rasi" 2>/dev/null | sed 's/.*style_\([0-9]*\).rasi/\1/')
[ -n "$CURRENT_STYLE" ] && rofi-layout.sh --refresh "$WALLPAPER" "$CURRENT_STYLE"

# 6. Reload desktop components

# Sway — only if running
pgrep -x sway >/dev/null 2>&1 && swaymsg reload

# Waybar — only if running
pgrep -x waybar >/dev/null 2>&1 && killall -SIGUSR2 waybar

# SwayNC — only if running
pgrep -x swaync >/dev/null 2>&1 && swaync-client -R && swaync-client -rs

# Kitty — reload theme in all running instances
pgrep -u "$USER" kitty >/dev/null 2>&1 && kill -SIGUSR1 $(pgrep -u "$USER" kitty)

# Spicetify — only if installed
command -v spicetify >/dev/null 2>&1 && kitty -e spicetify apply

# 7. Notify
notify-send -i "$WALLPAPER" "System Synced" "Config: $(basename "$WALLUST_CONFIG")"
