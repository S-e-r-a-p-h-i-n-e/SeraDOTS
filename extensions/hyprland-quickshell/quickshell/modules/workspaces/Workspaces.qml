// modules/workspaces/Workspaces.qml — BACKEND ONLY
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs.globals

QtObject {
    readonly property var workspaces: Hyprland.workspaces

    function activate(ws)      { ws.activate() }
    function focusWindow(addr) { Hyprland.dispatch("focuswindow address:0x" + addr) }

    // Delegates to globals/Icons.qml — single source of truth for all app icons.
    function iconFor(toplevel) {
        let appClass = ""
        if (toplevel.wayland && toplevel.wayland.appId) {
            appClass = toplevel.wayland.appId.toLowerCase()
        } else {
            let ipc = toplevel.lastIpcObject || {}
            appClass = (ipc["class"] || ipc["initialClass"] || toplevel.title || "?").toLowerCase()
        }
        return Icons.getIcon(appClass)
    }
}
