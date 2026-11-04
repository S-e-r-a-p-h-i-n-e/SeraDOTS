--  █▀ ▀█▀ ▄▀█ █▀█ ▀█▀ █░█  █▀█ █▀
--  ▄█ ░█░ █▀█ █▀▄ ░█░ █▄█  █▀▀ ▄█

-- --- Environment Variables ---
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")
hl.env("XDG_MENU_PREFIX", "arch-") -- Replace with what you use, e.g. gnome- for Gnome, kde- for KDE
hl.env("QML_XHR_ALLOW_FILE_READ", "1")
hl.env("QT_QPA_PLATFORMTHEME", "gtk3")

-- --- Autostart ---
hl.on("hyprland.start", function()
    hl.exec_cmd([[sh -c '. "$HOME/.config/SeraDOTS/env/env.sh"']])
    hl.exec_cmd("dbus-update-activation-environment --all WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_DESKTOP")
    hl.exec_cmd("systemctl --user restart wireplumber pipewire pipewire-pulse")
    hl.exec_cmd("systemctl --user restart xdg-desktop-portal-hyprland xdg-desktop-portal")
    hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")

    -- --- UI Components ---
    hl.exec_cmd("quickshell")
    hl.exec_cmd("swww-daemon")

    -- --- Clipboard & Tray ---
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
    hl.exec_cmd("nm-applet --indicator")
    hl.exec_cmd("blueman-applet")
    hl.exec_cmd("udiskie --tray")

    -- --- Idle Daemon ---
    hl.exec_cmd("hypridle")
end)
