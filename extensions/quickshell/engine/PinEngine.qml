// engine/PinEngine.qml — single source of truth for pinned app IDs
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.globals

Singleton {
    id: root

    property var pinned: []

    readonly property string pinnedFile: Quickshell.env("HOME") + "/.config/quickshell/pinned_apps.json"

    // JsonAdapter cannot handle root-level arrays, and array properties inside
    // JsonAdapter are also unreliable. The proven workaround (same as Config.qml's
    // dashboardLayout) is to store the array as a JSON string in a string property.
    // File format: { "pinned": "[\"vesktop\",\"spotify\"]" }
    FileView {
        id: pinnedFileView
        path: root.pinnedFile
        adapter: JsonAdapter {
            property string pinned: "[]"
            onPinnedChanged: {
                try {
                    root.pinned = JSON.parse(pinned) || []
                } catch(e) {
                    root.pinned = []
                }
            }
        }
    }

    function save() {
        pinnedFileView.setText(JSON.stringify({ pinned: JSON.stringify(pinned) }, null, 2))
    }

    function isPinned(appId) {
        return pinned.includes(appId)
    }

    function pin(appId) {
        if (!pinned.includes(appId)) {
            pinned = pinned.concat([appId])
            save()
        }
    }

    function unpin(appId) {
        pinned = pinned.filter(id => id !== appId)
        save()
    }

    function toggle(appId) {
        isPinned(appId) ? unpin(appId) : pin(appId)
    }

    // Resolve a raw appId string to its short form, e.g. "org.mozilla.firefox" -> "firefox"
    function shortId(appId) {
        let parts = (appId || "").toLowerCase().split(".")
        return parts[parts.length - 1] || appId
    }
}
