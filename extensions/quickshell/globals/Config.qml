// globals/Config.qml
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string configPath: Quickshell.env("HOME") + "/.config/quickshell/config.json"
    readonly property string tmpPath:    Quickshell.env("HOME") + "/.config/quickshell/.config.json.tmp"

    property string navbarLocation:    "top"
    property bool   enableBorders:     true
    property bool   transparentNavbar: false
    property string activeLayout:      "default"
    // Stored as JSON string since JsonAdapter doesn't support arrays directly
    property string dashboardLayout:   JSON.stringify(["stats","speaker","mic","network","idleinhibitor","media"])
    property string wallpaperPath:     ""

    // True once config.json has been read at least once.
    // Panel windows must not be created before this is true, because
    // Wayland layer-shell anchors are immutable after window creation —
    // if a PanelWindow is created with the hardcoded defaults above and
    // the saved value differs, the anchors can never be corrected.
    property bool loaded: false

    readonly property bool isHorizontal: navbarLocation === "top" || navbarLocation === "bottom"

    FileView {
        id: configFile
        path: root.configPath
        adapter: JsonAdapter {
            property string navbarLocation:    "top"
            property bool   enableBorders:     true
            property bool   transparentNavbar: false
            property string activeLayout:      "default"
            property string dashboardLayout:   ""
            property string wallpaperPath:     ""

            onNavbarLocationChanged: {
                root.navbarLocation = navbarLocation
                root.loaded = true
            }
            onEnableBordersChanged:     root.enableBorders     = enableBorders
            onTransparentNavbarChanged: root.transparentNavbar = transparentNavbar
            onActiveLayoutChanged:      root.activeLayout      = activeLayout
            onDashboardLayoutChanged:   { if (dashboardLayout !== "") root.dashboardLayout = dashboardLayout }
            onWallpaperPathChanged:     { if (wallpaperPath   !== "") root.wallpaperPath   = wallpaperPath   }
        }
    }

    // Fallback: if navbarLocation in the file matches the hardcoded default
    // ("top"), onNavbarLocationChanged never fires and loaded would stay false
    // forever. This timer ensures panels always appear after a short delay
    // regardless.
    Timer {
        interval: 150
        running:  !root.loaded
        repeat:   false
        onTriggered: root.loaded = true
    }

    readonly property var settingKeys: ["navbarLocation", "enableBorders", "transparentNavbar", "activeLayout", "dashboardLayout", "wallpaperPath"]

    function saveSetting(key, value) {
        root[key] = value

        let fileData = {}
        for (let k of root.settingKeys) fileData[k] = root[k]

        let jsonString = JSON.stringify(fileData, null, 2)
        Quickshell.execDetached({
            command: ["sh", "-c",
                `mkdir -p ~/.config/quickshell && echo '${jsonString}' > ${root.tmpPath} && mv ${root.tmpPath} ${root.configPath}`]
        })
    }
}
