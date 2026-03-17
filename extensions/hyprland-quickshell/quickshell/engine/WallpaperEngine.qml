// quickshell/engine/WallpaperEngine.qml
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property var wallpapers: []
    // Updated to match your SeraDOTS deployment tree
    readonly property string wallDir: Quickshell.env("HOME") + "/.config/YASD/wallpapers"

    Process {
        id: finder
        // Grab jpg, png, jpeg, and webp
        command: ["sh", "-c", "find '" + root.wallDir + "' -type f \\( -iname \\*.jpg -o -iname \\*.png -o -iname \\*.jpeg -o -iname \\*.webp \\)"]
        
        stdout: StdioCollector {
            onStreamFinished: {
                let files = this.text.split('\n').filter(p => p.trim().length > 0)
                let parsed = []
                
                for (let i = 0; i < files.length; i++) {
                    let path = files[i]
                    let name = path.substring(path.lastIndexOf('/') + 1)
                    parsed.push({ name: name, path: path })
                }
                
                // Sort alphabetically
                parsed.sort((a, b) => a.name.localeCompare(b.name))
                root.wallpapers = parsed
            }
        }
    }

    function refresh() {
        finder.running = true
    }

    // Executes your exact swww command natively
    function apply(path) {
        let cmd = "swww img '" + path + "' --transition-type grow --transition-pos 0.5,0.5 --transition-step 90"
        Quickshell.execDetached({ command: ["sh", "-c", cmd] })
    }

    Component.onCompleted: refresh()
}