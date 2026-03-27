// panels/PowerManager.qml — Full-screen power menu (wlogout-style, native QML)
import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.globals

Scope {
    id: rootScope

    property bool showPanel:    false
    property var  targetScreen: null

    // Animation state — true while fading in or out
    property bool isAnimating: false

    readonly property var actions: [
        { label: "Lock",     icon: "\uf023", command: " hyprlock || swaylock || loginctl lock-session"                      },
        { label: "Logout",   icon: "\udb82\udc98", command: "hyprctl dispatch exit || loginctl terminate-user \"$USER\""   },
        { label: "Suspend",  icon: "\uf28d", command: "loginctl suspend || zzz || echo mem > /sys/power/state"             },
        { label: "Reboot",   icon: "\uead2", command: "reboot"                                                             },
        { label: "Shutdown", icon: "\u23fb", command: "poweroff"                                                           },
    ]

    Variants {
        model: Config.loaded ? Quickshell.screens : []

        PanelWindow {
            required property var modelData

            readonly property bool isTargetScreen:
                !rootScope.targetScreen || rootScope.targetScreen.name === modelData.name

            screen:  modelData
            visible: overlayItem.opacity > 0 && isTargetScreen
            color:   "transparent"

            WlrLayershell.layer:         WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
            WlrLayershell.namespace:     "quickshell-power"
            exclusionMode:               ExclusionMode.Ignore

            anchors { top: true; bottom: true; left: true; right: true }

            // ── Escape to dismiss ──────────────────────────────────────────
            Shortcut {
                sequence: "Escape"
                onActivated: {
                    if (rootScope.showPanel && !rootScope.isAnimating)
                        EventBus.togglePanel("power", null)
                }
            }

            Item {
                id: overlayItem
                anchors.fill: parent

                opacity: rootScope.showPanel && isTargetScreen ? 1.0 : 0.0
                Behavior on opacity {
                    NumberAnimation {
                        id: overlayAnim
                        duration: Animations.normal
                        easing.type: Animations.easeInOut
                        onRunningChanged: rootScope.isAnimating = running
                    }
                }

                // ── Dimmed background — click to dismiss ───────────────────
                Rectangle {
                    anchors.fill: parent
                    color: Qt.rgba(0, 0, 0, 0.6)

                    MouseArea {
                        anchors.fill: parent
                        enabled:      !rootScope.isAnimating
                        onClicked:    EventBus.togglePanel("power", null)
                    }
                }

                // ── Card row ───────────────────────────────────────────────
                Row {
                    anchors.centerIn: parent
                    spacing: 16

                    Repeater {
                        model: rootScope.actions

                        delegate: Rectangle {
                            required property var  modelData
                            required property int  index

                            width:  200
                            height: 260
                            radius: 16
                            color:  cardMouse.containsMouse
                                    ? Qt.rgba(Colors.foreground.r, Colors.foreground.g, Colors.foreground.b, 0.12)
                                    : Qt.rgba(Colors.foreground.r, Colors.foreground.g, Colors.foreground.b, 0.06)
                            border.color: cardMouse.containsMouse
                                    ? Qt.rgba(Colors.foreground.r, Colors.foreground.g, Colors.foreground.b, 0.35)
                                    : Qt.rgba(Colors.foreground.r, Colors.foreground.g, Colors.foreground.b, 0.12)
                            border.width: 1

                            // Slide-up + fade in with stagger
                            opacity: overlayItem.opacity
                            transform: Translate {
                                y: overlayItem.opacity < 1.0
                                   ? (1.0 - overlayItem.opacity) * 40
                                   : 0
                                Behavior on y {
                                    NumberAnimation { duration: Animations.normal; easing.type: Animations.easeOut }
                                }
                            }

                            Behavior on color        { ColorAnimation  { duration: Animations.fast } }
                            Behavior on border.color { ColorAnimation  { duration: Animations.fast } }

                            Column {
                                anchors.centerIn: parent
                                spacing: 24

                                // Icon
                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text:                     modelData.icon
                                    font.pixelSize:           72
                                    font.family:              "JetBrainsMono Nerd Font"
                                    color:                    cardMouse.containsMouse
                                                              ? Colors.foreground
                                                              : Qt.rgba(Colors.foreground.r, Colors.foreground.g, Colors.foreground.b, 0.75)
                                    Behavior on color { ColorAnimation { duration: Animations.fast } }
                                }

                                // Label
                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text:                     modelData.label
                                    font.pixelSize:           18
                                    font.family:              Style.barFont
                                    font.weight:              Font.Medium
                                    color:                    cardMouse.containsMouse
                                                              ? Colors.foreground
                                                              : Qt.rgba(Colors.foreground.r, Colors.foreground.g, Colors.foreground.b, 0.65)
                                    Behavior on color { ColorAnimation { duration: Animations.fast } }
                                }
                            }

                            // Scale on hover
                            scale: cardMouse.containsMouse ? 1.04 : 1.0
                            Behavior on scale {
                                NumberAnimation { duration: Animations.fast; easing.type: Animations.easeOut }
                            }

                            MouseArea {
                                id: cardMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                enabled:      !rootScope.isAnimating
                                cursorShape:  Qt.PointingHandCursor

                                onClicked: {
                                    EventBus.togglePanel("power", null)
                                    // Small delay so the panel closes before the action fires
                                    actionTimer.command = modelData.command
                                    actionTimer.restart()
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // Fire the system command after the panel has started closing
    Timer {
        id: actionTimer
        property string command: ""
        interval: Animations.normal + 50
        onTriggered: {
            if (command !== "")
                Quickshell.execDetached({ command: ["sh", "-c", command] })
        }
    }
}
