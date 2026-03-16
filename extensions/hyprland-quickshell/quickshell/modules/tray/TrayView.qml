// modules/tray/TrayView.qml — FRONTEND ONLY
import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import qs.globals
import qs.modules.tray

Item {
    id: root

    property bool isHorizontal: Config.isHorizontal
    property real barThickness: Style.moduleSize
    property bool inPill:       false

    readonly property real dotSize:     barThickness
    readonly property real iconSize:    dotSize * 0.55
    readonly property real itemSpacing: Style.chipSpacing

    implicitWidth:  isHorizontal ? container.implicitWidth  : barThickness
    implicitHeight: isHorizontal ? barThickness              : container.implicitHeight

    // Pill background
    Rectangle {
        visible: !root.inPill && Tray.items.length > 0
        anchors.centerIn: parent
        width:  root.isHorizontal ? container.implicitWidth + dotSize * 0.6 : root.barThickness
        height: root.isHorizontal ? root.barThickness                        : container.implicitHeight + dotSize * 0.6
        radius: (root.isHorizontal ? height : width) / 2
        color:   Colors.color7
        opacity: 0.325
    }

    Grid {
        id: container
        anchors.centerIn: parent
        columns: root.isHorizontal ? 0 : 1
        rows:    root.isHorizontal ? 1 : 0
        spacing: root.itemSpacing

        Repeater {
            model: Tray.items

            delegate: Item {
                id: trayItem
                required property var modelData

                width:  root.dotSize
                height: root.dotSize

                Rectangle {
                    anchors.centerIn: parent
                    width:  root.dotSize
                    height: root.dotSize
                    radius: height / 2
                    color:  itemArea.containsMouse ? Colors.foreground : Colors.color7
                    Behavior on color { ColorAnimation { duration: 150 } }

                    Text {
                        anchors.centerIn: parent
                        text:           Tray.iconFor(trayItem.modelData)
                        color:          itemArea.containsMouse ? Colors.foreground : Colors.color3
                        Behavior on color { ColorAnimation { duration: 150 } }
                        font.family:    Style.barFont
                        font.pixelSize: root.iconSize
                        font.weight:    Font.Bold
                    }
                }

                QsMenuAnchor {
                    id: menuAnchor
                    anchor.window: trayItem.QsWindow.window
                    menu: trayItem.modelData.menu
                }

                MouseArea {
                    id: itemArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape:  Qt.PointingHandCursor
                    acceptedButtons: Qt.LeftButton | Qt.RightButton

                    onClicked: (e) => {
                        if (e.button === Qt.LeftButton && trayItem.modelData.hasMenu) {
                            menuAnchor.open()
                        } else {
                            trayItem.modelData.activate()
                        }
                    }
                }
            }
        }
    }
}
