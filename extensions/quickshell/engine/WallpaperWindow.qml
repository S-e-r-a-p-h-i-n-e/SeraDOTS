// engine/WallpaperWindow.qml
// Self-contained wallpaper renderer — just add WallpaperWindow {} to shell.qml.
// Spawns one background PanelWindow per screen via Variants internally.
// Features: crossfade, parallax on empty desktop, smart video pause.
import QtQuick
import QtMultimedia
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.globals

Scope {
    id: root

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: win
            required property var modelData

            screen:        modelData
            color:         "black"
            visible:       true
            exclusionMode: ExclusionMode.Ignore

            WlrLayershell.layer:         WlrLayer.Background
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
            WlrLayershell.namespace:     "quickshell-wallpaper"

            anchors { top: true; bottom: true; left: true; right: true }

            // ── Path resolution ───────────────────────────────────────────
            readonly property string rawPath:      Config.wallpaperPath
            readonly property string resolvedPath: rawPath.startsWith("~")
                ? rawPath.replace("~", Quickshell.env("HOME"))
                : rawPath
            readonly property bool isVideo: rawPath.match(/\.(mp4|webm|mkv|mov|avi)$/i) !== null

            // ── Smart video pausing ───────────────────────────────────────
            // Pause video when any window is focused, play when desktop is empty.
            property bool noWindowFocused: !Hyprland.activeToplevel

            readonly property bool shouldPlayVideo: isVideo && noWindowFocused

            onShouldPlayVideoChanged: {
                if (!isVideo) return
                if (player.playbackState !== MediaPlayer.StoppedState)
                    shouldPlayVideo ? player.play() : player.pause()
            }

            Connections {
                target: Hyprland
                ignoreUnknownSignals: true
                function onActiveToplevelChanged() {
                    win.noWindowFocused = !Hyprland.activeToplevel
                }
            }

            // ── Crossfade: two image layers, alternating ──────────────────
            property string path1:    ""
            property string path2:    ""
            property bool   useFirst: true

            Component.onCompleted: {
                if (!isVideo && resolvedPath !== "")
                    path1 = "file://" + resolvedPath
            }

            onResolvedPathChanged: {
                if (!isVideo && resolvedPath !== "") {
                    useFirst = !useFirst
                    if (useFirst) path1 = "file://" + resolvedPath
                    else          path2 = "file://" + resolvedPath
                }
            }

            // ── Parallax ──────────────────────────────────────────────────
            Item {
                id: parallax
                anchors.fill: parent
                // Slight scale-up so edge shift doesn't reveal black border
                scale: 1.06

                property real targetX: 0
                property real targetY: 0

                transform: Translate {
                    x: parallax.targetX
                    y: parallax.targetY
                    Behavior on x { NumberAnimation { duration: 800; easing.type: Easing.OutCubic } }
                    Behavior on y { NumberAnimation { duration: 800; easing.type: Easing.OutCubic } }
                }

                // Reset parallax when a window is focused
                Connections {
                    target: win
                    function onNoWindowFocusedChanged() {
                        if (!win.noWindowFocused) {
                            parallax.targetX = 0
                            parallax.targetY = 0
                        }
                    }
                }

                // ── Image layer A ─────────────────────────────────────────
                Image {
                    anchors.fill:  parent
                    source:        win.path1
                    fillMode:      Image.PreserveAspectCrop
                    asynchronous:  true
                    smooth:        true
                    mipmap:        true
                    sourceSize:    Qt.size(win.width, win.height)
                    opacity:       (!win.isVideo && win.useFirst && win.path1 !== "") ? 1 : 0
                    Behavior on opacity { NumberAnimation { duration: 800; easing.type: Easing.InOutCubic } }
                }

                // ── Image layer B ─────────────────────────────────────────
                Image {
                    anchors.fill:  parent
                    source:        win.path2
                    fillMode:      Image.PreserveAspectCrop
                    asynchronous:  true
                    smooth:        true
                    mipmap:        true
                    sourceSize:    Qt.size(win.width, win.height)
                    opacity:       (!win.isVideo && !win.useFirst && win.path2 !== "") ? 1 : 0
                    Behavior on opacity { NumberAnimation { duration: 800; easing.type: Easing.InOutCubic } }
                }

                // ── Video output ──────────────────────────────────────────
                VideoOutput {
                    id:           videoOut
                    anchors.fill: parent
                    fillMode:     VideoOutput.PreserveAspectCrop
                    opacity:      win.isVideo ? 1 : 0
                    Behavior on opacity { NumberAnimation { duration: 800; easing.type: Easing.InOutCubic } }
                }
            }

            // MediaPlayer lives outside parallax — no need to transform audio/decode
            AudioOutput {
                id:     audioOut
                volume: 0.0
            }

            MediaPlayer {
                id:          player
                source:      (win.isVideo && win.resolvedPath !== "") ? "file://" + win.resolvedPath : ""
                audioOutput: audioOut
                videoOutput: videoOut
                loops:       MediaPlayer.Infinite
                autoPlay:    true
            }

            // ── Parallax mouse tracking ───────────────────────────────────
            // Only active when desktop is empty (no focused window)
            MouseArea {
                anchors.fill:    parent
                hoverEnabled:    win.noWindowFocused
                acceptedButtons: Qt.NoButton

                onPositionChanged: (mouse) => {
                    let ox = (mouse.x - width  / 2) / (width  / 2)
                    let oy = (mouse.y - height / 2) / (height / 2)
                    parallax.targetX = -ox * 20
                    parallax.targetY = -oy * 20
                }
                onExited: {
                    parallax.targetX = 0
                    parallax.targetY = 0
                }
            }
        }
    }
}
