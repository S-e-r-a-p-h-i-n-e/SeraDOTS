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
    // finder.command only runs once at startup so static binding is fine here
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
        property string _buf: ""
        stdout: SplitParser { onRead: (l) => { if (l.trim()) finder._buf += l.trim() + "\n" } }
        onExited: {
            let files  = _buf.split('\n').filter(p => p.trim().length > 0)
            _buf = ""
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

    function refresh() { finder.running = true }

    // ── Apply ─────────────────────────────────────────────────────────────
    function apply(path) {
        if (isVideo(path)) {
            _applyVideo(path)
        } else {
            _applyImage(path)
        }
        ThemeSyncEngine.sync(path, isVideo(path))
    }

    function _applyImage(path) {
        // Always kill mpvpaper unconditionally — it may have been started
        // outside the engine (e.g. by wallchange.sh directly), so we can't
        // rely on activeBackend being set.
        let kill        = "pkill -x mpvpaper 2>/dev/null || true; sleep 0.3; "
        let daemonGuard = "pgrep -x swww-daemon >/dev/null 2>&1 || { swww-daemon & sleep 0.5; }; "
        let swww        = "swww img '" + path + "' --transition-type grow --transition-pos 0.5,0.5 --transition-step 90"
        Quickshell.execDetached({ command: ["sh", "-c", kill + daemonGuard + swww] })
        activeBackend = "swww"
    }

    function _applyVideo(path) {
        // Always kill both backends unconditionally — matches wallchange.sh
        // behaviour and handles the case where a video was set externally
        // (activeBackend = "") so the old conditional guard would skip the kill.
        let kill =
            "pkill -x mpvpaper 2>/dev/null || true; " +
            "pkill -x swww-daemon 2>/dev/null || true; " +
            "sleep 0.5; "

        // Detect connected monitor name — mpvpaper requires the actual output
        // name. Mirrors the two-stage detection in wallchange.sh exactly.
        let monitorCmd =
            "MONITOR=\"\"; " +
            "if command -v hyprctl >/dev/null 2>&1; then " +
            "  MONITOR=$(hyprctl monitors -j 2>/dev/null | grep -m1 '\"name\"' | sed 's/.*\"name\": *\"\\([^\"]*\\)\".*/\\1/'); " +
            "fi; " +
            "if [ -z \"$MONITOR\" ]; then " +
            "  MONITOR=$(find /sys/class/drm -name status 2>/dev/null " +
            "    | xargs grep -l '^connected$' 2>/dev/null " +
            "    | head -n 1 " +
            "    | xargs dirname 2>/dev/null " +
            "    | xargs basename 2>/dev/null " +
            "    | sed 's/card[0-9]*-//'); " +
            "fi; " +
            "if [ -z \"$MONITOR\" ]; then " +
            "  notify-send 'Wallpaper Error' 'Could not detect monitor name for mpvpaper'; " +
            "  exit 1; " +
            "fi; "

        let mpv = "mpvpaper -f -o 'no-audio loop' \"$MONITOR\" '" + path + "'"
        Quickshell.execDetached({ command: ["sh", "-c", kill + monitorCmd + mpv] })
        activeBackend = "mpvpaper"
    }

    Component.onCompleted: refresh()
}
