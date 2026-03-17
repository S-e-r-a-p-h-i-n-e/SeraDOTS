// panels/Settings.qml
import Quickshell
import QtQuick
import QtQuick.Controls
import qs.components
import qs.globals

Panel {
    id: settingsPanel


    property bool bordersEnabled: Config.enableBorders

    Column {
        anchors.fill: parent
        spacing: 0

        // ── Header ────────────────────────────────────────────────────────
        Text {
            text:           "󰒓  Settings"
            color:          Colors.foreground
            font.family:    Style.barFont
            font.pixelSize: 18
            font.weight:    Font.ExtraBold
            anchors.horizontalCenter: parent.horizontalCenter
            bottomPadding:  16
        }

        Rectangle { width: parent.width; height: 1; color: Colors.color8; opacity: 0.5 }

        // ── Scrollable content ────────────────────────────────────────────
        ScrollView {
            id: scroll
            width:  parent.width
            height: parent.height - 18 - 16 - 1
            clip:   true

            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded
                contentItem: Rectangle {
                    implicitWidth: 4
                    radius:        2
                    color:         Colors.color7
                    opacity:       0.5
                }
            }

            Column {
                width:      scroll.width
                spacing:    20
                topPadding: 16

                // ── Toggles ───────────────────────────────────────────────
                Column {
                    width:   parent.width
                    spacing: 15

                    Toggle {
                        labelText: "Show Borders"
                        checked:   settingsPanel.bordersEnabled
                        disabled:  Config.transparentNavbar
                        onToggled: (state) => EventBus.toggleBorders(state)
                    }
                    Toggle {
                        labelText: "Transparency"
                        checked:   Config.transparentNavbar
                        disabled:  settingsPanel.bordersEnabled
                        onToggled: (state) => EventBus.toggleTransparentNavbar(state)
                    }
                }

                Rectangle { width: parent.width; height: 1; color: Colors.color8; opacity: 0.5 }

                // ── Navbar position ───────────────────────────────────────
                Text {
                    text:           "Navbar Position"
                    color:          Colors.foreground
                    font.family:    Style.barFont
                    font.pixelSize: 14
                    font.weight:    Font.Bold
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Item {
                    width:  130
                    height: 130
                    anchors.horizontalCenter: parent.horizontalCenter

                    Button { anchors { top: parent.top; horizontalCenter: parent.horizontalCenter }
                             labelText: "󰁝"; labelFont: Style.barFont
                             buttonSize: 40; buttonColor: Colors.color7
                             onButtonClicked: EventBus.changeLocation("top") }
                    Button { anchors { bottom: parent.bottom; horizontalCenter: parent.horizontalCenter }
                             labelText: "󰁅"; labelFont: Style.barFont
                             buttonSize: 40; buttonColor: Colors.color7
                             onButtonClicked: EventBus.changeLocation("bottom") }
                    Button { anchors { left: parent.left; verticalCenter: parent.verticalCenter }
                             labelText: "󰁍"; labelFont: Style.barFont
                             buttonSize: 40; buttonColor: Colors.color7
                             onButtonClicked: EventBus.changeLocation("left") }
                    Button { anchors { right: parent.right; verticalCenter: parent.verticalCenter }
                             labelText: "󰁔"; labelFont: Style.barFont
                             buttonSize: 40; buttonColor: Colors.color7
                             onButtonClicked: EventBus.changeLocation("right") }
                }

                Rectangle { width: parent.width; height: 1; color: Colors.color8; opacity: 0.5 }

                // ── Layout switcher ───────────────────────────────────────
                Text {
                    text:           "Bar Layout"
                    color:          Colors.foreground
                    font.family:    Style.barFont
                    font.pixelSize: 14
                    font.weight:    Font.Bold
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Flow {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width:   parent.width - 40
                    spacing: 2

                    Repeater {
                        model: ["default", "minimal", "media",
                                "01","02","03","04","05","06",
                                "07","08","09"]
                        delegate: Rectangle {
                            required property string modelData
                            width:  (parent.width - (parent.spacing * 3)) / 4
                            height: 28; 
                            radius: 14
                            color:  Config.activeLayout === modelData ? Colors.color7 : Colors.color0
                            Behavior on color { ColorAnimation { duration: 150 } }

                            Text {
                                anchors.centerIn: parent
                                text:            parent.modelData
                                color:           Config.activeLayout === parent.modelData ? Colors.background : Colors.foreground
                                font.family:     Style.barFont
                                font.pixelSize:  11
                                font.weight:     Font.Bold
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape:  Qt.PointingHandCursor
                                onClicked:    EventBus.changeLayout(parent.modelData)
                            }
                        }
                    }
                }

                Rectangle { width: parent.width; height: 1; color: Colors.color8; opacity: 0.5 }

                // ── Advanced Settings ─────────────────────────────────────
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width:  parent.width - 40
                    height: 36
                    radius: 18
                    color:  advArea.containsMouse ? Colors.color7 : Colors.color0
                    Behavior on color { ColorAnimation { duration: 150 } }

                    Text {
                        anchors.centerIn: parent
                        text:           "󰒓  Advanced Settings"
                        color:          advArea.containsMouse ? Colors.background : Colors.foreground
                        Behavior on color { ColorAnimation { duration: 150 } }
                        font.family:    Style.barFont
                        font.pixelSize: 13
                        font.weight:    Font.Bold
                    }

                    MouseArea {
                        id: advArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape:  Qt.PointingHandCursor
                        onClicked:    EventBus.togglePanel("advanced", settingsPanel.targetScreen)
                    }
                }

                Item { width: 1; height: 4 }
            }
        }
    }
}