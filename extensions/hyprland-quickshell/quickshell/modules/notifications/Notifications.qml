// modules/notifications/Notifications.qml — BACKEND
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import qs.globals

Singleton {
    id: root

    readonly property string moduleType: "static"

    readonly property var item: ({
        icon:      root.count > 0 ? "󰂚" : "󰂜",
        onClicked: function(screen) { EventBus.togglePanel("dashboard", screen) }
    })

    // Use a ListModel so mutations are properly reactive in Repeater
    property ListModel notifications: ListModel {}
    readonly property int count: notifications.count

    function dismissAt(index) {
        if (index >= 0 && index < notifications.count)
            notifications.remove(index, 1)
    }

    function dismissAll() {
        notifications.clear()
    }

    NotificationServer {
        id: server
        keepOnReload: true

        onNotification: (n) => {
            // Replace existing notification with same replaces_id if set
            if (n.replacesId > 0) {
                for (let i = 0; i < root.notifications.count; i++) {
                    if (root.notifications.get(i).notifId === n.replacesId) {
                        root.notifications.set(i, {
                            notifId:  n.id,
                            app:      n.appName   || "",
                            summary:  n.summary   || "",
                            body:     n.body      || "",
                            time:     Qt.formatDateTime(new Date(), "HH:mm")
                        })
                        return
                    }
                }
            }

            // Insert newest first
            root.notifications.insert(0, {
                notifId:  n.id,
                app:      n.appName   || "",
                summary:  n.summary   || "",
                body:     n.body      || "",
                time:     Qt.formatDateTime(new Date(), "HH:mm")
            })

            // Cap at 50
            while (root.notifications.count > 50)
                root.notifications.remove(root.notifications.count - 1, 1)
        }
    }
}
