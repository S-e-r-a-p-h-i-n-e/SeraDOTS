COMMAND=$1

if pidof systemd > /dev/null 2>&1; then
    INIT_SYS="systemd"
else
    INIT_SYS="runit"
fi

case "$COMMAND" in
    "lock")
        swaylock
        ;;
    "logout")
        swaymsg exit
        ;;
    "suspend")
        if [ "$INIT_SYS" = "systemd" ]; then
            systemctl suspend
        else
            loginctl suspend
        fi
        ;;
    "reboot")
        if [ "$INIT_SYS" = "systemd" ]; then
            systemctl reboot
        else
            loginctl reboot
        fi
        ;;
    "shutdown")
        if [ "$INIT_SYS" = "systemd" ]; then
            systemctl poweroff
        else
            loginctl poweroff
        fi
        ;;
esac