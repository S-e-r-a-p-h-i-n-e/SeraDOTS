// engine/ClipboardEngine.qml
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property var history: []
    property var favorites: []
    
    readonly property string favFile: Quickshell.env("HOME") + "/.config/SeraDOTS/clipboard_favorites.txt"

    // 1. Fetch normal history
    Process {
        id: historyProcess
        command: ["sh", "-c", "cliphist list"]
        stdout: StdioCollector {
            onStreamFinished: {
                let lines = this.text.split('\n').filter(l => l.trim().length > 0)
                let parsed = []
                for (let i = 0; i < lines.length; i++) {
                    let parts = lines[i].split('\t')
                    if (parts.length >= 2) {
                        parsed.push({ id: lines[i], content: parts.slice(1).join('\t') })
                    }
                }
                root.history = parsed
            }
        }
    }

    // 2. Fetch Favorites natively via JS
    function refreshFavorites() {
        Quickshell.execDetached({ command: ["sh", "-c", "touch '" + favFile + "'"] })
        let xhr = new XMLHttpRequest()
        try {
            xhr.open("GET", "file://" + favFile, false)
            xhr.send()
            if (xhr.readyState === 4 && (xhr.status === 200 || xhr.status === 0)) {
                root.favorites = xhr.responseText.split('\n').filter(l => l.trim().length > 0)
            }
        } catch (e) {
            console.warn("Could not read favorites file")
        }
    }

    function refresh() {
        historyProcess.running = true
        refreshFavorites()
    }

    // --- Actions ---

    function copyHistory(id) {
        let cmd = "printf '%s\\n' '" + id + "' | cliphist decode | wl-copy"
        Quickshell.execDetached({ command: ["sh", "-c", cmd] })
    }

    function copyFavorite(text) {
        // Escape single quotes so it doesn't break the bash command
        let safeText = text.replace(/'/g, "'\\''")
        let cmd = "printf '%s' '" + safeText + "' | wl-copy && notify-send -u low -h string:x-canonical-private-synchronous:clip 'Clipboard' 'Favorite Copied'"
        Quickshell.execDetached({ command: ["sh", "-c", cmd] })
    }

    function addFavorite(id) {
        // Mimicking your exact script logic to preserve newlines
        let cmd = "echo \"$(printf '%s\\n' '" + id + "' | cliphist decode)\" >> '" + favFile + "' && notify-send -u low -h string:x-canonical-private-synchronous:clip 'Clipboard' 'Added to Favorites 🌟'"
        Quickshell.execDetached({ command: ["sh", "-c", cmd] })
        
        // Refresh the lists after a tiny delay so the file system has time to write
        updateTimer.start() 
    }

    function removeFavorite(text) {
        let safeText = text.replace(/'/g, "'\\''")
        // Your exact awk deletion command translated
        let cmd = "awk -v target='" + safeText + "' '$0 == target && !done {done=1; next} 1' '" + favFile + "' > '" + favFile + ".tmp' && mv '" + favFile + ".tmp' '" + favFile + "' && notify-send -u low -h string:x-canonical-private-synchronous:clip 'Clipboard' 'Removed from Favorites ❌'"
        Quickshell.execDetached({ command: ["sh", "-c", cmd] })
        updateTimer.start()
    }

    function wipe() {
        Quickshell.execDetached({ command: ["sh", "-c", "cliphist wipe && notify-send -u low -h string:x-canonical-private-synchronous:clip 'Clipboard' 'History Cleared 🗑️'"] })
        root.history = []
    }

    Timer {
        id: updateTimer
        interval: 150
        onTriggered: refresh()
    }

    Component.onCompleted: refresh()
}