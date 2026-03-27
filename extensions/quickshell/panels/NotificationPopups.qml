// panels/NotificationPopups.qml — Live notification toast popups
import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.globals
import qs.modules.notifications

Scope {
    id: rootScope

    // How far to inset from the screen edge (plus bar if on that side)
    readonly property int margin:    16
    readonly property int popupWidth: 380

    Variants {
        model: Config.loaded ? Quickshell.screens : []

        PanelWindow {
            required property var modelData
            screen: modelData

            // Always visible — individual cards handle their own visibility
            visible:      Notifications.popups.count > 0
            color:        "transparent"

            WlrLayershell.layer:         WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
            WlrLayershell.namespace:     "quickshell-notif-popups"
            exclusionMode:               ExclusionMode.Ignore

            anchors {
                top:   true
                right: true
            }

            implicitWidth:  rootScope.popupWidth + rootScope.margin * 2
            implicitHeight: popupColumn.implicitHeight + rootScope.margin * 2

            // Stack of toast cards
            Column {
                id: popupColumn
                anchors {
                    top:   parent.top
                    right: parent.right
                    margins: rootScope.margin
                }
                width:   rootScope.popupWidth
                spacing: 8

                // Newest-first — model is already inserted at index 0
                Repeater {
                    model: Notifications.popups

                    delegate: NotificationCard {
                        required property var  modelData
                        required property int  index

                        width:     rootScope.popupWidth
                        popupId:   modelData.popupId
                        app:       modelData.app
                        summary:   modelData.summary
                        body:      modelData.body
                        icon:      modelData.icon
                        urgency:   modelData.urgency
                        timeout:   modelData.timeout
                    }
                }
            }
        }
    }
}
