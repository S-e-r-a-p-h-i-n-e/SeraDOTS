if makoctl mode | grep -q "^dnd$"; then
    makoctl mode -r dnd
    notify-send -u low "Notifications" "Enabled (Normal Mode)"
else
    makoctl mode -a dnd
    notify-send -u low "Notifications" "Disabled (DND Active)"
fi

pkill -RTMIN+8 waybar