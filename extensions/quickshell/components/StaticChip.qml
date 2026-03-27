// components/StaticChip.qml
// Engine container for static modules (power, tray, notifications, cliphist, etc).
// Modules pass in a single item descriptor — this component owns all layout,
// sizing, orientation, and interaction. Modules own nothing visual.
//
// The `item` object should have:
//   icon:        string   — nerd font glyph
//   bgColor:     color    — background (optional, falls back to Colors.color7)
//   fgColor:     color    — icon color (optional, falls back to Colors.color3)
//   active:      bool     — whether to show active/highlight state (optional)
//   activeColor: color    — color when active (optional, falls back to Colors.color7)
//   onClicked:   function — left click handler (optional)
//   onRightClicked: function — right click handler (optional)

import QtQuick
import qs.globals

Item {
    id: root

    property bool   isHorizontal: true
    property real   barThickness: 28
    property bool   inPill:       false
    property string barFont:      "JetBrainsMono Nerd Font"
    property var    barScreen:    null

    // The module populates this — single item descriptor object
    property var item: ({})

    implicitWidth:  barThickness
    implicitHeight: barThickness

    Rectangle {
        anchors.centerIn: parent
        width:  root.barThickness
        height: root.barThickness
        radius: height / 2

        readonly property color resolvedBg: root.item.active
            ? (root.item.activeColor ?? Colors.color7)
            : (root.item.bgColor ?? Colors.color7)

        color: resolvedBg
        Behavior on color { ColorAnimation { duration: 150 } }

        Text {
            anchors.centerIn: parent
            text:           root.item.icon ?? ""
            font.family:    root.barFont
            font.pixelSize: root.barThickness * 0.6
            color:          root.item.active
                ? Colors.color3
                : (root.item.fgColor ?? Colors.color3)
        }

        MouseArea {
            anchors.fill:    parent
            cursorShape:     Qt.PointingHandCursor
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            onClicked: (e) => {
                if (e.button === Qt.RightButton) {
                    if (root.item.onRightClicked) root.item.onRightClicked(root.barScreen)
                } else {
                    if (root.item.onClicked) root.item.onClicked(root.barScreen)
                }
            }
        }
    }
}
