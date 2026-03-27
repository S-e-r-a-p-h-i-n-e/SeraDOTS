// engine/AppEngine.qml
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property var applications: []
    property bool loading: true

    Process {
        id: fileFinder
        command: ["sh", "-c", "find ~/.local/share/applications /usr/share/applications /var/lib/flatpak/exports/share/applications -type f -name '*.desktop' 2>/dev/null"]
        
        // Use StdioCollector to gather all the output from the find command
        stdout: StdioCollector {
            onStreamFinished: {
                // 'this.text' contains the entire multi-line string output
                let files = this.text.split('\n').filter(path => path.trim().length > 0)
                parseDesktopFiles(files)
            }
        }
    }

    function parseDesktopFiles(filePaths) {
        let apps = []
        let seen = {}

        for (let i = 0; i < filePaths.length; i++) {
            let content = readFile(filePaths[i])
            if (!content) continue

            let lines = content.split('\n')
            let name = ""
            let icon = ""
            let execCmd = ""
            let nodisplay = false
            let inDesktopEntry = false

            for (let j = 0; j < lines.length; j++) {
                let line = lines[j].trim()
                
                if (line === "[Desktop Entry]") {
                    inDesktopEntry = true
                    continue
                } else if (line.startsWith("[")) {
                    inDesktopEntry = false
                    continue
                }

                if (inDesktopEntry) {
                    if (line.startsWith("Name=") && !name) {
                        name = line.substring(5).trim()
                    } else if (line.startsWith("Icon=") && !icon) {
                        icon = line.substring(5).trim()
                    } else if (line.startsWith("Exec=") && !execCmd) {
                        execCmd = line.substring(5).trim()
                    } else if (line.startsWith("NoDisplay=") && line.substring(10).trim().toLowerCase() === "true") {
                        nodisplay = true
                    }
                }
            }

            if (name && execCmd && !nodisplay) {
                execCmd = execCmd.split("%")[0].trim()
                
                if (!seen[name]) {
                    seen[name] = true
                    apps.push({
                        "name": name,
                        "icon": icon,
                        "exec": execCmd
                    })
                }
            }
        }

        apps.sort((a, b) => a.name.toLowerCase().localeCompare(b.name.toLowerCase()))
        
        root.applications = apps
        root.loading = false
    }

    function readFile(filePath) {
        let xhr = new XMLHttpRequest()
        try {
            xhr.open("GET", "file://" + filePath, false) 
            xhr.send()
            
            if (xhr.readyState === 4 && (xhr.status === 200 || xhr.status === 0)) {
                return xhr.responseText
            }
        } catch (e) {
            console.warn("Could not read file: " + filePath)
        }
        return ""
    }

    function refresh() {
        root.loading = true
        fileFinder.running = true
    }

    Component.onCompleted: refresh()
}