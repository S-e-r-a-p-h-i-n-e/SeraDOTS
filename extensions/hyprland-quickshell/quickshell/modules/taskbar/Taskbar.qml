pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.globals

QtObject {
    id: root

    // Persisted pinned app IDs — survives restarts
    property var pinned: []

    readonly property string pinnedFile: Quickshell.env("HOME") + "/.config/quickshell/pinned_apps.json"

    property var pinnedFileView: FileView {
        path: root.pinnedFile
        onLoaded: {
            try {
                root.pinned = JSON.parse(text)
            } catch(e) {
                root.pinned = []
            }
        }
    }

    function savePinned() {
        pinnedFileView.setText(JSON.stringify(pinned, null, 2))
    }

    // The merged display list
    readonly property var displayList: {
        let running = ToplevelManager.toplevels.values
        // Start with pinned slots
        let result = pinned.map(appId => {
            let live = running.find(t => {
                let id = (t.appId || "").toLowerCase()
                let parts = id.split(".")
                return parts[parts.length - 1] === appId || id === appId
            })
            return {
                appId:    appId,
                toplevel: live ?? null,
                pinned:   true,
                running:  live != null
            }
        })
        // Append unpinned running windows
        for (let t of running) {
            let id = (t.appId || "").toLowerCase()
            let parts = id.split(".")
            let shortId = parts[parts.length - 1]
            let alreadyPinned = pinned.includes(shortId) || pinned.includes(id)
            if (!alreadyPinned) {
                result.push({
                    appId:    shortId,
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

    function pin(entry) {
        if (!pinned.includes(entry.appId)) {
            pinned = pinned.concat([entry.appId])
            savePinned()
        }
    }

    function unpin(entry) {
        pinned = pinned.filter(id => id !== entry.appId)
        savePinned()
    }

    function togglePin(entry) {
        if (entry.pinned) unpin(entry)
        else pin(entry)
    }

    function iconFor(entry) {
        return Icons.getIcon(entry.appId)
    }
}