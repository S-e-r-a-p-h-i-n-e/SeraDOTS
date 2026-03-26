import QtQuick
import qs.globals
import qs.modules.taskbar

Item {
    id: root

    property bool isHorizontal: Config.isHorizontal
    property real barThickness: Style.moduleSize
    property bool inPill:       false

    readonly property real dotSize:     barThickness
    readonly property real iconSize:    dotSize * 0.75
    readonly property real itemSpacing: Style.slotSpacing

    implicitWidth: isHorizontal
        ? (repeater.count > 0 ? repeater.count * (dotSize + itemSpacing) - itemSpacing : 0)
        : barThickness
    implicitHeight: isHorizontal
        ? barThickness
        : (repeater.count > 0 ? repeater.count * (dotSize + itemSpacing) - itemSpacing : 0)

    Row {
        anchors.centerIn: parent
        spacing: root.itemSpacing

        Repeater {
            id: repeater
            model: Taskbar.displayList

            delegate: Item {
                id: appDot
                required property var modelData
                required property int index

                width:  root.dotSize
                height: root.dotSize

                readonly property bool isActive: modelData.running &&
                    modelData.toplevel && modelData.toplevel.activated

                Rectangle {
                    anchors.centerIn: parent
                    width:  root.dotSize
                    height: root.dotSize
                    radius: root.dotSize / 2

                    // Pinned but not running: dimmer, dashed feel via opacity
                    color: appArea.containsMouse
                        ? Colors.foreground
                        : appDot.isActive
                            ? Colors.color0
                            : Colors.color7
                    opacity: modelData.running ? 1.0 : 0.4
                    Behavior on color   { ColorAnimation { duration: 150 } }
                    Behavior on opacity { NumberAnimation { duration: 150 } }

                    Text {
                        anchors.centerIn: parent
                        text:           Taskbar.iconFor(appDot.modelData)
                        color:          appArea.containsMouse
                            ? Colors.background
                            : (appDot.isActive ? Colors.background : Colors.color0)
                        Behavior on color { ColorAnimation { duration: 150 } }
                        font.family:    Style.barFont
                        font.pixelSize: root.iconSize
                        font.weight:    Font.Bold
                    }

                    // Small dot indicator at the bottom for running apps
                    Rectangle {
                        visible: modelData.running
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 2
                        width:  4
                        height: 4
                        radius: 2
                        color:  appDot.isActive ? Colors.color7 : Colors.color3
                    }
                }

                MouseArea {
                    id: appArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape:  Qt.PointingHandCursor
                    acceptedButtons: Qt.LeftButton | Qt.RightButton

                    onClicked: (event) => {
                        if (event.button === Qt.RightButton) {
                            // Right click toggles pin
                            Taskbar.togglePin(modelData)
                        } else {
                            if (modelData.running && appDot.isActive) {
                                Taskbar.minimize(modelData)
                            } else {
                                Taskbar.activate(modelData)
                            }
                        }
                    }
                }
            }
        }
    }
}