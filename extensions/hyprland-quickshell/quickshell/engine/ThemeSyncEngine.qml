// engine/ThemeSyncEngine.qml
// Native QML port of theme-sync.sh for the hyprland-quickshell extension.
// Each step runs as a sequential Process chain.
//
// Dead steps from theme-sync.sh omitted:
//   swaymsg reload          — not running in hyprland-quickshell
//   killall -SIGUSR2 waybar — not running
//   swaync-client           — replaced by native NotificationPopups
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string home:         Quickshell.env("HOME")
    readonly property string snapDir:      "/tmp/wallchange_snaps"
    readonly property string wallustDark:  home + "/.config/wallust/wallust-dark.toml"
    readonly property string wallustLight: home + "/.config/wallust/wallust-light.toml"

    property bool   syncing:    false
    property string _wallpaper: ""
    property string _sample:    ""
    property bool   _isVideo:   false

    property string _wallustConfig: wallustDark
    property string _kvantumTheme:  "MateriaDark"
    property string _gtkTheme:      "Materia-dark"
    property string _gtkDark:       "1"
    property string _colorScheme:   "prefer-dark"

    // ── Public entry point ────────────────────────────────────────────────
    function sync(wallpaperPath, isVideo) {
        if (root.syncing) return
        root.syncing    = true
        root._wallpaper = wallpaperPath
        root._isVideo   = isVideo

        if (isVideo) {
            let name     = wallpaperPath.substring(wallpaperPath.lastIndexOf("/") + 1)
            root._sample = snapDir + "/" + name + ".jpg"
            snapProc.running = true
        } else {
            root._sample = wallpaperPath
            brightnessProc.running = true
        }
    }

    // ── Step 0 (video only) — extract snapshot frame ──────────────────────
    Process {
        id: snapProc
        command: [
            "sh", "-c",
            "mkdir -p '" + root.snapDir + "'; " +
            "OUT='" + root._sample + "'; " +
            "if [ -f \"$OUT\" ]; then printf '%s' \"$OUT\"; exit 0; fi; " +
            "ffmpeg -ss 5 -i '" + root._wallpaper + "' -frames:v 1 -q:v 2 \"$OUT\" -y >/dev/null 2>&1 || " +
            "ffmpeg        -i '" + root._wallpaper + "' -frames:v 1 -q:v 2 \"$OUT\" -y >/dev/null 2>&1; " +
            "[ -f \"$OUT\" ] && printf '%s' \"$OUT\""
        ]
        stdout: StdioCollector {
            onStreamFinished: {
                let snap = this.text.trim()
                if (snap !== "") {
                    root._sample = snap
                    brightnessProc.running = true
                } else {
                    console.warn("ThemeSyncEngine: snapshot extraction failed")
                    root.syncing = false
                }
            }
        }
    }

    // ── Step 1 — brightness detection ─────────────────────────────────────
    Process {
        id: brightnessProc
        command: [
            "sh", "-c",
            "magick '" + root._sample + "' -colorspace Gray -format '%[fx:100*median]' info:"
        ]
        stdout: StdioCollector {
            onStreamFinished: {
                let val     = parseFloat(this.text.trim())
                let isLight = !isNaN(val) && val > 60

                root._wallustConfig = isLight ? root.wallustLight  : root.wallustDark
                root._kvantumTheme  = isLight ? "MateriaLight"     : "MateriaDark"
                root._gtkTheme      = isLight ? "Materia-light"    : "Materia-dark"
                root._gtkDark       = isLight ? "0"                : "1"
                root._colorScheme   = isLight ? "prefer-light"     : "prefer-dark"

                wallustProc.running = true
            }
        }
    }

    // ── Step 2 — wallust ──────────────────────────────────────────────────
    Process {
        id: wallustProc
        command: [
            "wallust", "run", "-C", root._wallustConfig, root._sample
        ]
        onRunningChanged: { if (!running) kvantumProc.running = true }
    }

    // ── Step 3 — Kvantum ──────────────────────────────────────────────────
    Process {
        id: kvantumProc
        command: ["kvantummanager", "--set", root._kvantumTheme]
        onRunningChanged: { if (!running) gtkProc.running = true }
    }

    // ── Step 4 — GTK settings.ini + gsettings live reload ─────────────────
    Process {
        id: gtkProc
        command: [
            "sh", "-c",
            "GTK_THEME='" + root._gtkTheme + "'; " +
            "GTK_DARK='" + root._gtkDark + "'; " +
            "COLOR_SCHEME='" + root._colorScheme + "'; " +
            "for f in \"$HOME/.config/gtk-3.0/settings.ini\" \"$HOME/.config/gtk-4.0/settings.ini\"; do " +
            "  [ -f \"$f\" ] || continue; " +
            "  sed -i \"s/^gtk-theme-name=.*/gtk-theme-name=$GTK_THEME/\" \"$f\"; " +
            "  sed -i \"s/^gtk-application-prefer-dark-theme=.*/gtk-application-prefer-dark-theme=$GTK_DARK/\" \"$f\"; " +
            "done; " +
            "command -v gsettings >/dev/null 2>&1 && { " +
            "  gsettings set org.gnome.desktop.interface gtk-theme \"$GTK_THEME\"; " +
            "  gsettings set org.gnome.desktop.interface color-scheme \"$COLOR_SCHEME\"; " +
            "}"
        ]
        onRunningChanged: { if (!running) rofiProc.running = true }
    }

    // ── Step 5 — rofi thumbnail + kitty reload ────────────────────────────
    Process {
        id: rofiProc
        command: [
            "sh", "-c",
            "CURRENT_STYLE=$(readlink \"$HOME/.config/rofi/layout.rasi\" 2>/dev/null | " +
            "  sed 's/.*style_\\([0-9]*\\).rasi/\\1/'); " +
            "[ -n \"$CURRENT_STYLE\" ] && command -v rofi-layout.sh >/dev/null 2>&1 && " +
            "  rofi-layout.sh --refresh '" + root._sample + "' \"$CURRENT_STYLE\"; " +
            "pgrep -u \"$USER\" kitty >/dev/null 2>&1 && " +
            "  kill -SIGUSR1 $(pgrep -u \"$USER\" kitty)"
        ]
        onRunningChanged: { if (!running) spicetifyProc.running = true }
    }

    // ── Step 6 — spicetify ────────────────────────────────────────────────
    // Uses Quickshell.execDetached with a login shell — same pattern as
    // Updates.qml's kitty launch which is confirmed working.
    Process {
        id: spicetifyProc
        command: ["sh", "-c", "true"]  // no-op — spicetify fires via execDetached
        onRunningChanged: {
            if (!running) {
                Quickshell.execDetached({ command: ["/bin/bash", "-l", "-c", "kitty -e spicetify apply"] })
                notifyProc.running = true
            }
        }
    }

    // ── Step 7 — notify ───────────────────────────────────────────────────
    Process {
        id: notifyProc
        command: [
            "notify-send",
            "-i", root._sample,
            "System Synced",
            "Config: " + root._wallustConfig.substring(root._wallustConfig.lastIndexOf("/") + 1)
        ]
        onRunningChanged: { if (!running) root.syncing = false }
    }
}
