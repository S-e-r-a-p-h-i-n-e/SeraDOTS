// engine/WallpaperEngine.qml — SeraDOTS / hyprland-quickshell
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property var    wallpapers:    []
    property string activeBackend: ""   // "swww" | "mpvpaper" | ""

    readonly property string wallDir:   Quickshell.env("HOME") + "/.config/SeraDOTS/wallpapers"
    readonly property string home:      Quickshell.env("HOME")
    readonly property var    videoExts: ["mp4", "webm", "mkv", "mov", "avi"]

    function isVideo(path) {
        let ext = path.substring(path.lastIndexOf('.') + 1).toLowerCase()
        return videoExts.indexOf(ext) !== -1
    }

    // ── File discovery ────────────────────────────────────────────────────
    Process {
        id: finder
        command: [
            "sh", "-c",
            "find '" + root.wallDir + "' -type f \\( " +
            "-iname \\*.jpg -o -iname \\*.jpeg -o -iname \\*.png -o " +
            "-iname \\*.webp -o -iname \\*.gif -o " +
            "-iname \\*.mp4 -o -iname \\*.webm -o -iname \\*.mkv -o " +
            "-iname \\*.mov -o -iname \\*.avi \\)"
        ]
        stdout: StdioCollector {
            onStreamFinished: {
                let files  = this.text.split('\n').filter(p => p.trim().length > 0)
                let parsed = []
                for (let i = 0; i < files.length; i++) {
                    let path  = files[i]
                    let name  = path.substring(path.lastIndexOf('/') + 1)
                    let ext   = name.substring(name.lastIndexOf('.') + 1).toLowerCase()
                    let video = root.videoExts.indexOf(ext) !== -1
                    let gif   = ext === "gif"
                    parsed.push({ name, path, video, gif })
                }
                parsed.sort((a, b) => a.name.localeCompare(b.name))
                root.wallpapers = parsed
            }
        }
    }

    function refresh() { finder.running = true }

    // ── Apply ─────────────────────────────────────────────────────────────
    function apply(path) {
        if (isVideo(path)) {
            _applyVideo(path)
            // No theme sync for video — no static frame to sample
        } else {
            _applyImage(path)
            _runThemeSync(path)
        }
    }

    function _applyImage(path) {
        let kill = activeBackend === "mpvpaper"
            ? "pkill -x mpvpaper; sleep 0.3; "
            : ""
        let cmd = kill + "swww img '" + path + "' --transition-type grow --transition-pos 0.5,0.5 --transition-step 90"
        Quickshell.execDetached({ command: ["sh", "-c", cmd] })
        activeBackend = "swww"
    }

    function _applyVideo(path) {
        let kill = activeBackend !== "" ? "pkill -x mpvpaper; pkill -x swww-daemon; sleep 0.3; " : ""
        let cmd  = kill + "mpvpaper -o 'no-audio loop' '*' '" + path + "'"
        Quickshell.execDetached({ command: ["sh", "-c", cmd] })
        activeBackend = "mpvpaper"
    }

    // ── Theme sync — brightness detection then theme-sync.sh ──────────────
    // Matches wallchange.sh: measure brightness, pick config, call theme-sync.sh
    property string _pendingPath: ""

    function _runThemeSync(path) {
        _pendingPath = path
        brightnessProc.running = true
    }

    Process {
        id: brightnessProc
        command: [
            "sh", "-c",
            "magick '" + root._pendingPath + "' -colorspace Gray -format \"%[fx:100*median]\" info:"
        ]
        stdout: StdioCollector {
            onStreamFinished: {
                let val = parseFloat(this.text.trim())
                let isLight = !isNaN(val) && val > 60

                let wallustConfig = isLight
                    ? root.home + "/.config/wallust/wallust-light.toml"
                    : root.home + "/.config/wallust/wallust-dark.toml"
                let kvantumTheme = isLight ? "MateriaLight" : "MateriaDark"

                // Call theme-sync.sh with the same args as wallchange.sh
                Quickshell.execDetached({
                    command: ["/bin/bash", "-l", "-c",
                        "theme-sync.sh '" + root._pendingPath + "' '" + wallustConfig + "' '" + kvantumTheme + "'"
                    ]
                })
            }
        }
    }

    Component.onCompleted: refresh()
}
