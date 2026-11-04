// components/StyleDropdown.qml
import QtQuick
import QtQuick.Controls
import qs.globals

Item {
    id: root

    // ── Properties matching Toggle 1:1 ────────────────────────────────────
    property string label:    ""
    property var    options:      []
    property string currentValue: ""
    property bool   disabled:     false

    signal committed(string newValue)

    implicitWidth:  parent ? parent.width : 200
    implicitHeight: 30

    opacity: root.disabled ? 0.35 : 1.0
    Behavior on opacity { NumberAnimation { duration: 150 } }

    Text {
        anchors.left:           parent.left
        anchors.verticalCenter: parent.verticalCenter
        text:                   root.label
        color:                  Colors.foreground
        font.family:            "JetBrainsMono Nerd Font"
        font.pixelSize:         14
        font.weight:            Font.Bold
    }

    Rectangle {
        id: selectorBox
        anchors.right:          parent.right
        anchors.verticalCenter: parent.verticalCenter
        width:                  120
        height:                 32
        radius:                 6
        color:                  Colors.color5

        border.width: 1
        border.color: dropdownMouse.containsMouse && !root.disabled ? Colors.color5 : "transparent"
        Behavior on border.color { ColorAnimation { duration: 150 } }

        Row {
            anchors.fill: parent
            anchors.leftMargin: 8
            anchors.rightMargin: 8
            spacing: 4

            Text {
                text: {
                    let s = root.currentValue
                    if (!s) return "Select..."
                    return s.charAt(0).toUpperCase() + s.slice(1)
                }
                color:          Colors.background
                font.family:    "JetBrainsMono Nerd Font"
                font.pixelSize: 12
                anchors.verticalCenter: parent.verticalCenter
                elide:          Text.ElideRight
                width:          parent.width - arrowIcon.width - parent.spacing
            }

            Text {
                id:             arrowIcon
                text:           "▾"
                color:          dropdownMouse.containsMouse && !root.disabled ? Colors.color5 : Colors.color8
                font.pixelSize: 10
                anchors.verticalCenter: parent.verticalCenter
                Behavior on color { ColorAnimation { duration: 150 } }
            }
        }

        Menu {
            id: popupMenu
            y:      selectorBox.height + 4
            width:  selectorBox.width

            background: Rectangle {
                color:        Colors.color0
                border.color: Colors.color8
                border.width: 1
                radius:       6
            }

            Instantiator {
                model: root.options
                onObjectAdded:   (index, object) => popupMenu.insertItem(index, object)
                onObjectRemoved: (index, object) => popupMenu.removeItem(object)

                delegate: MenuItem {
                    text: modelData

                    contentItem: Text {
                        text:              parent.text
                        font.family:       "JetBrainsMono Nerd Font"
                        font.pixelSize:    12
                        color:             parent.hovered ? Colors.color5 : Colors.foreground
                        verticalAlignment: Text.AlignVCenter
                    }

                    background: Rectangle {
                        color: parent.hovered ? Qt.rgba(1, 1, 1, 0.05) : "transparent"
                    }

                    onTriggered: {
                        root.committed(modelData)
                    }
                }
            }
        }

        MouseArea {
            id:           dropdownMouse
            anchors.fill: parent
            hoverEnabled: !root.disabled
            cursorShape:  root.disabled ? Qt.ForbiddenCursor : Qt.PointingHandCursor
            onClicked:    if (!root.disabled) popupMenu.open()
        }
    }
}
