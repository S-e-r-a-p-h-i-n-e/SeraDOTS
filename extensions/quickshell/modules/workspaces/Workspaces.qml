// modules/workspaces/Workspaces.qml — BACKEND ONLY
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs.globals
import qs.engine

QtObject {
    readonly property var workspaces: Hyprland.workspaces

    function activate(ws)      { ws.activate() }
    function focusWindow(addr) { Hyprland.dispatch("focuswindow address:0x" + addr) }

    function iconFor(toplevel) {
        return Icons.getIcon(appIdFor(toplevel))
    }

    function appIdFor(toplevel) {
        let appClass = ""
        if (toplevel.wayland && toplevel.wayland.appId) {
            appClass = toplevel.wayland.appId.toLowerCase()
        } else {
            let ipc = toplevel.lastIpcObject || {}
            appClass = (ipc["class"] || ipc["initialClass"] || toplevel.title || "?").toLowerCase()
        }
        return PinEngine.shortId(appClass)
    }

    function isPinned(toplevel) {
        return PinEngine.isPinned(appIdFor(toplevel))
    }

    function togglePin(toplevel) {
        PinEngine.toggle(appIdFor(toplevel))
    }
}
