// modules/workspaces/Workspaces.qml — BACKEND ONLY
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland

QtObject {
    readonly property var workspaces: Hyprland.workspaces

    function activate(ws)      { ws.activate() }
    function focusWindow(addr) { Hyprland.dispatch("focuswindow address:0x" + addr) }

    readonly property var iconMap: ({
        "firefox":           "󰈹",
        "librewolf":         "󰈹",
        "kitty":             "󰄛",
        "alacritty":         "󰄛",
        "discord":           "󰙯",
        "vesktop":           "󰙯",
        "code":              "󰨞",
        "code-oss":          "󰨞",
        "unity":             "󰚯",
        "unityhub":          "󰚯",
        "spotify":           "󰓇",
        "steam":             "󰓓",
        "obs":               "󰑋",
        "vlc":               "󰕼",
        "mpv":               "󰕼",
        "thunar":            "󰉋",
        "nautilus":          "󰉋",
        "org.kde.dolphin":   "󰉋",
        "cs2":               "󰖺",
        "csgo":              "󰖺",
        "valorant":          "󰖺",
        "osu!":              "󰣄"
    })

    function iconFor(toplevel) {
        let appClass = ""
        if (toplevel.wayland && toplevel.wayland.appId) {
            appClass = toplevel.wayland.appId.toLowerCase()
        } else {
            let ipc = toplevel.lastIpcObject || {}
            appClass = (ipc["class"] || ipc["initialClass"] || toplevel.title || "?").toLowerCase()
        }
        return iconMap[appClass] || appClass.substring(0, 1).toUpperCase()
    }
}
