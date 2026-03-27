// components/IconImage.qml
// Unified icon resolver for app icons across YAQC.
// Handles three source types in priority order:
//   1. Absolute path  (/usr/share/icons/…, /path/to/app.png)
//   2. XDG icon name  (resolves via Qt's image://icon/ provider)
//   3. Empty/missing  (shows nothing — no broken image placeholder)
//
// Usage:
//   IconImage { iconName: model.appIcon; size: 24 }
//   IconImage { iconName: notification.icon; size: 18 }

import QtQuick

Item {
    id: root

    property string iconName: ""
    property int    size:     24

    implicitWidth:  size
    implicitHeight: size

    // Resolve source from iconName — same logic as Launcher.qml, centralised here
    readonly property string resolvedSource: {
        if (!iconName || iconName === "") return ""
        if (iconName.startsWith("/"))      return "file://" + iconName
        return "image://icon/" + iconName
    }

    Image {
        anchors.fill: parent
        source:       root.resolvedSource
        visible:      root.resolvedSource !== "" && status === Image.Ready
        fillMode:     Image.PreserveAspectFit
        smooth:       true
        mipmap:       true
        asynchronous: true
    }
}
