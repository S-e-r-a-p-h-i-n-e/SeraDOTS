# Idle Inhibitor Notifier for Waybar
STATE_FILE="/tmp/waybar_idle_state"

if [ ! -f "$STATE_FILE" ]; then
    # File doesn't exist, meaning it was OFF and is now turning ON
    touch "$STATE_FILE"
    notify-send -u low -h string:x-canonical-private-synchronous:idle "Display" "Idle Inhibitor: ON "
else
    # File exists, meaning it was ON and is now turning OFF
    rm "$STATE_FILE"
    notify-send -u low -h string:x-canonical-private-synchronous:idle "Display" "Idle Inhibitor: OFF "
fi

