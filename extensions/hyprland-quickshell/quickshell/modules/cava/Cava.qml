// modules/cava/Cava.qml — BACKEND ONLY (native cava parser)
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.globals

QtObject {
    id: root // Added ID for reliable internal referencing

    readonly property string moduleType: "custom"

    property string bars:    "▁▁▁▁▁▁▁▁"
    property bool   present: false

    property var blockMap: [
        " "," "," "," "," ",
        "▂","▂","▂","▂",
        "▃","▃","▃","▃",
        "▄","▄","▄","▄",
        "▅","▅","▅","▅",
        "▆","▆","▆","▆",
        "▇","▇","▇","▇",
        "█","█","█","█"
    ]

    function parseBars(line) {
        // Remove trailing semicolon to prevent a trailing empty space
        line = line.replace(/;$/, "")
        let parts = line.split(";")
        let out = ""

        for (let i = 0; i < parts.length; i++) {
            let v = parseInt(parts[i])
            // Ensure the value is within the bounds of blockMap
            if (!isNaN(v) && v >= 0 && v < blockMap.length)
                out += blockMap[v]
            else
                out += " "
        }

        return out
    }

    property var _check: Process {
        id: checkProc
        command: ["bash", "-c", "command -v cava >/dev/null 2>&1 && echo yes || echo no"]
        running: true

        stdout: SplitParser {
            onRead: (l) => {
                if (l.trim() === "yes") {
                    root.present = true
                    cavaProc.running = true
                }
            }
        }
    }

    property var _proc: Process {
        id: cavaProc

        // Pass through bash to correctly expand the '~' to the user's home directory
        command: ["bash", "-c", "cava -p ~/.config/cava/config-waybar"]

        running: false

        stdout: SplitParser {
            onRead: (l) => {
                let t = l.trim()
                if (!t) return

                root.bars = root.parseBars(t)
            }
        }

        onExited: {
            if (root.present) {
                // Use a timer instead of callLater to prevent a rapid infinite crash loop
                restartTimer.start()
            }
        }
    }

    // Timer to safely restart cava if it exits
    property var _timer: Timer {
        id: restartTimer
        interval: 1000 // 1-second delay
        onTriggered: cavaProc.running = true
    }
}