pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.globals
import qs.engine

Singleton {
    id: root

    // The merged display list: pinned slots first, then unpinned running windows
    readonly property var displayList: {
        let running = ToplevelManager.toplevels.values
        let result = PinEngine.pinned.map(appId => {
            let live = running.find(t => {
                let id = (t.appId || "").toLowerCase()
                return PinEngine.shortId(id) === appId || id === appId
            })
            return {
                appId:    appId,
                toplevel: live ?? null,
                pinned:   true,
                running:  live != null
            }
        })
        for (let t of running) {
            let id  = (t.appId || "").toLowerCase()
            let sid = PinEngine.shortId(id)
            if (!PinEngine.isPinned(sid) && !PinEngine.isPinned(id)) {
                result.push({
                    appId:    sid,
                    toplevel: t,
                    pinned:   false,
                    running:  true
                })
            }
        }
        return result
    }

    property var launcher: Process {
        id: launcher
    }

    function activate(entry) {
        if (entry.running) {
            entry.toplevel.activate()
        } else {
            launcher.command = [entry.appId]
            launcher.running = true
        }
    }

    function minimize(entry) {
        if (entry.running) {
            entry.toplevel.minimized = true
        }
    }

    function togglePin(entry) {
        PinEngine.toggle(entry.appId)
    }

    function iconFor(entry) {
        return Icons.getIcon(entry.appId)
    }
}
