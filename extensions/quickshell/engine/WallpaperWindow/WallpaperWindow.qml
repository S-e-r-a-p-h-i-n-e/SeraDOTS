// engine/WallpaperWindow/WallpaperWindow.qml
// Entry point — spawns one WallpaperRenderer per screen.
import QtQuick
import Quickshell
import qs.globals

Scope {
    Variants {
        model: Quickshell.screens
        WallpaperRenderer {
            required property var modelData
            screen: modelData
        }
    }
}
