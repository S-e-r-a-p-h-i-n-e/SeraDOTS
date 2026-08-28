// engine/ThemeSyncEngine.qml
// Native QML port of theme-sync.sh
//
// Step 2 (wallust) writes ~/.cache/quickshell/wallust-colors.json, a plain
// data file, not a live .qml source — so it no longer triggers Quickshell's
// own hot-reload the way it did when wallust overwrote Colors.qml directly.
// Step 2 therefore runs as a tracked Process, and its onExited calls
// Colors.reload() explicitly. Steps 3-7 (kvantum, gtk, rofi, spicetify,
// notify) still run detached — nothing in QML needs their completion.
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.globals

Singleton {
    id: root

    readonly property string home:         Quickshell.env("HOME")
    readonly property string snapDir:      "/tmp/wallchange_snaps"
    readonly property string wallustDark:  home + "/.config/wallust/wallust-dark.toml"
    readonly property string wallustLight: home + "/.config/wallust/wallust-light.toml"

    property bool   syncing:    false
    property string _wallpaper: ""
    property string _sample:    ""

    // ── Public entry point ────────────────────────────────────────────────
    function sync(wallpaperPath, isVideo) {
        if (root.syncing) {
            console.log("ThemeSync: already syncing, ignoring call")
            return
        }
        console.log("ThemeSync: sync() called — path=" + wallpaperPath + " isVideo=" + isVideo)
        root.syncing    = true
        root._wallpaper = wallpaperPath

        if (isVideo) {
            let name     = wallpaperPath.substring(wallpaperPath.lastIndexOf("/") + 1)
            root._sample = snapDir + "/" + name + ".jpg"
            _startSnap()
        } else {
            root._sample = wallpaperPath
            _startBrightness()
        }
    }

    // ── Step 0 (video only) — extract snapshot ────────────────────────────
    function _startSnap() {
        console.log("ThemeSync: [0] snap start")
        snapProc.command = [
            "sh", "-c",
            "mkdir -p '" + root.snapDir + "'; " +
            "OUT='" + root._sample + "'; " +
            "if [ -f \"$OUT\" ]; then printf '%s' \"$OUT\"; exit 0; fi; " +
            "ffmpeg -ss 5 -i '" + root._wallpaper + "' -frames:v 1 -q:v 2 \"$OUT\" -y >/dev/null 2>&1 || " +
            "ffmpeg        -i '" + root._wallpaper + "' -frames:v 1 -q:v 2 \"$OUT\" -y >/dev/null 2>&1; " +
            "[ -f \"$OUT\" ] && printf '%s' \"$OUT\""
        ]
        snapProc.running = true
    }

    Process {
        id: snapProc
        property string _buf: ""
        stdout: SplitParser { onRead: (l) => { snapProc._buf = l.trim() } }
        onExited: (code) => {
            let snap = _buf.trim()
            _buf = ""
            console.log("ThemeSync: [0] snap exited code=" + code + " snap='" + snap + "'")
            if (snap !== "") {
                root._sample = snap
                _startBrightness()
            } else {
                console.warn("ThemeSync: snapshot extraction FAILED — aborting")
                root.syncing = false
            }
        }
    }

    // ── Step 1 — brightness detection ─────────────────────────────────────
    function _startBrightness() {
        console.log("ThemeSync: [1] brightness start — sample=" + root._sample)
        brightnessProc.command = [
            "sh", "-c",
            "magick '" + root._sample + "' -colorspace Gray -format '%[fx:100*median]' info:"
        ]
        brightnessProc.running = true
    }

    Process {
        id: brightnessProc
        property string _buf: ""
        stdout: SplitParser { onRead: (l) => { brightnessProc._buf = l.trim() } }
        onExited: (code) => {
            let val     = parseFloat(_buf.trim())
            _buf = ""
            let isLight = !isNaN(val) && val > 60
            console.log("ThemeSync: [1] brightness exited code=" + code + " val=" + val + " isLight=" + isLight)

            let wallustConfig = isLight ? root.wallustLight : root.wallustDark
            let kvantumTheme  = isLight ? "MateriaLight"    : "MateriaDark"
            let gtkTheme      = isLight ? "Materia-light"   : "Materia-dark"
            let gtkDark       = isLight ? "0"               : "1"
            let colorScheme   = isLight ? "prefer-light"    : "prefer-dark"

            _runPostBrightness(wallustConfig, kvantumTheme, gtkTheme, gtkDark, colorScheme)
        }
    }

    // ── Steps 2-7 ─────────────────────────────────────────────────────────
    // Step 2 (wallust) now runs as a tracked Process, not execDetached — its
    // target is a plain JSON cache file, not a live .qml source, so there is
    // no hot-reload for it to race against anymore. Its onExited is the only
    // reliable signal we have that wallust-colors.json is ready, so it drives
    // Colors.reload() directly. Steps 3-7 (kvantum/gtk/rofi/spicetify/notify)
    // stay detached — nothing in QML needs to know when those finish.
    function _runPostBrightness(wallustConfig, kvantumTheme, gtkTheme, gtkDark, colorScheme) {
        console.log("ThemeSync: [2-7] starting — kvantum=" + kvantumTheme)

        root._pendingKvantum     = kvantumTheme
        root._pendingGtkTheme    = gtkTheme
        root._pendingGtkDark     = gtkDark
        root._pendingColorScheme = colorScheme
        root._pendingConfigName  = wallustConfig.substring(wallustConfig.lastIndexOf("/") + 1)

        wallustProc.command = [
            "sh", "-c",
            "kitty -e wallust run -C '" + wallustConfig + "' '" + root._sample + "'"
        ]
        wallustProc.running = true
    }

    property string _pendingKvantum:     ""
    property string _pendingGtkTheme:    ""
    property string _pendingGtkDark:     ""
    property string _pendingColorScheme: ""
    property string _pendingConfigName:  ""

    Process {
        id: wallustProc
        onExited: (code) => {
            console.log("ThemeSync: [2] wallust exited code=" + code)
            // wallust-colors.json is written by this point regardless of the
            // exit code path taken inside the kitty window, so reload either
            // way — a stale palette is easier to notice and fix than a
            // silently-stuck one.
            Colors.reload()
            Config.saveSetting("wallustSyncedWallpaper", root._wallpaper)
            root._runRest()
        }
    }

    function _runRest() {
        let cmd =
            // 3. kvantum
            "kvantummanager --set '" + root._pendingKvantum + "'; " +

            // 4. gtk settings.ini + gsettings
            "GTK_THEME='" + root._pendingGtkTheme + "'; " +
            "GTK_DARK='" + root._pendingGtkDark + "'; " +
            "COLOR_SCHEME='" + root._pendingColorScheme + "'; " +
            "for f in \"$HOME/.config/gtk-3.0/settings.ini\" \"$HOME/.config/gtk-4.0/settings.ini\"; do " +
            "  [ -f \"$f\" ] || continue; " +
            "  sed -i \"s/^gtk-theme-name=.*/gtk-theme-name=$GTK_THEME/\" \"$f\"; " +
            "  sed -i \"s/^gtk-application-prefer-dark-theme=.*/gtk-application-prefer-dark-theme=$GTK_DARK/\" \"$f\"; " +
            "done; " +
            "command -v gsettings >/dev/null 2>&1 && { " +
            "  gsettings set org.gnome.desktop.interface gtk-theme \"$GTK_THEME\"; " +
            "  gsettings set org.gnome.desktop.interface color-scheme \"$COLOR_SCHEME\"; " +
            "}; " +

            // 5. rofi layout refresh + kitty theme reload
            "CURRENT_STYLE=$(readlink \"$HOME/.config/rofi/layout.rasi\" 2>/dev/null | " +
            "  sed 's/.*style_\\([0-9]*\\).rasi/\\1/'); " +
            "[ -n \"$CURRENT_STYLE\" ] && command -v rofi-layout.sh >/dev/null 2>&1 && " +
            "  rofi-layout.sh --refresh '" + root._sample + "' \"$CURRENT_STYLE\"; " +
            "pgrep -u \"$USER\" kitty >/dev/null 2>&1 && " +
            "  kill -SIGUSR1 $(pgrep -u \"$USER\" kitty); " +

            // 6. spicetify (guarded)
            "command -v spicetify >/dev/null 2>&1 && kitty -e spicetify apply; " +

            // 7. notify
            "notify-send -i '" + root._sample + "' 'System Synced' " +
            "'Config: " + root._pendingConfigName + "'"

        Quickshell.execDetached({ command: ["sh", "-c", cmd] })
        root.syncing = false
    }
}
