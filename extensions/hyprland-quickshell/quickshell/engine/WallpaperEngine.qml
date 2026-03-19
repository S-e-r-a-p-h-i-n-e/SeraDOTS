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
            _runThemeSync(path)   // extracts snapshot then syncs
        } else {
            _applyImage(path)
            _runThemeSync(path)
        }
    }

    function _applyImage(path) {
        // Always kill mpvpaper — it may have been started outside the engine
        let kill = "pkill -x mpvpaper 2>/dev/null || true; sleep 0.3; "
        // Ensure swww-daemon is running — it may have been killed for mpvpaper
        let daemonGuard = "pgrep -x swww-daemon >/dev/null 2>&1 || { swww-daemon & sleep 0.5; }; "
        let cmd = kill + daemonGuard +
            "swww img '" + path + "' --transition-type grow --transition-pos 0.5,0.5 --transition-step 90"
        Quickshell.execDetached({ command: ["sh", "-c", cmd] })
        activeBackend = "swww"
    }

    function _applyVideo(path) {
        let kill = activeBackend !== "" ? "pkill -x mpvpaper 2>/dev/null || true; pkill -x swww-daemon 2>/dev/null || true; sleep 0.5; " : ""
        // Detect monitor name — mpvpaper requires the actual output name, not a wildcard
        let monitorCmd =
            "MONITOR=\"\"; " +
            "if command -v hyprctl >/dev/null 2>&1; then " +
            "  MONITOR=$(hyprctl monitors -j 2>/dev/null | grep -m1 '\"name\"' | sed 's/.*\"name\": *\"\\([^\"]*\\)\".*/\\1/'); " +
            "fi; " +
            "if [ -z \"$MONITOR\" ]; then " +
            "  MONITOR=$(find /sys/class/drm -name status 2>/dev/null | xargs grep -l '^connected$' 2>/dev/null | head -n 1 | xargs dirname 2>/dev/null | xargs basename 2>/dev/null | sed 's/card[0-9]*-//'); " +
            "fi; "
        let cmd = kill + monitorCmd +
            "mpvpaper -f -o 'no-audio loop' \"$MONITOR\" '" + path + "'"
        Quickshell.execDetached({ command: ["sh", "-c", cmd] })
        activeBackend = "mpvpaper"
    }

    // ── Theme sync ────────────────────────────────────────────────────────
    // Delegates to ThemeSyncEngine which is a native QML port of theme-sync.sh.
    // For videos, passes the snapshot path so wallust gets a valid image.
    readonly property string snapDir: "/tmp/wallchange_snaps"

    function _runThemeSync(path) {
        ThemeSyncEngine.sync(path, isVideo(path))
    }
    Component.onCompleted: refresh()
}
