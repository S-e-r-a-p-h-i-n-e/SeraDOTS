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

    // ── Persistent notification center (dashboard) ─────────────────────────
    property ListModel notifications: ListModel {}
    readonly property int count: notifications.count

    function dismissAt(index) {
        if (index >= 0 && index < notifications.count)
            notifications.remove(index, 1)
    }

    function dismissAll() {
        notifications.clear()
    }

    // ── Live popup queue ───────────────────────────────────────────────────
    // Each entry: { popupId, app, summary, body, urgency, timeout, icon }
    // timeout: ms until auto-dismiss. 0 = never (critical).
    property ListModel popups: ListModel {}

    function dismissPopup(popupId) {
        for (let i = 0; i < root.popups.count; i++) {
            if (root.popups.get(i).popupId === popupId) {
                root.popups.remove(i, 1)
                return
            }
        }
    }

    function dismissAllPopups() {
        root.popups.clear()
    }

    // Emitted when a replace lands on an existing popup so the card can reset its timer
    signal popupReplaced(int oldId, int newId)

    // ── Notification server ────────────────────────────────────────────────
    NotificationServer {
        id: server
        keepOnReload: true

        onNotification: (n) => {
            try {
                // Safe property access — property names vary across Quickshell builds
                const urgency   = (typeof n.urgency      !== "undefined") ? n.urgency      : 1
                const rawMs     = (typeof n.expireTimeout !== "undefined") ? n.expireTimeout : -1

                // Resolve timeout: respect app hint, fall back to urgency-based defaults
                // urgency 2 (critical) = never auto-dismiss
                // urgency 0 (low)      = 3 s
                // urgency 1 (normal)   = 5 s
                const timeoutMs = urgency === 2  ? 0
                                : rawMs > 0      ? rawMs
                                : urgency === 0  ? 3000
                                :                  5000

                // ── Update popup queue ─────────────────────────────────────
                if (n.replacesId > 0) {
                    for (let i = 0; i < root.popups.count; i++) {
                        if (root.popups.get(i).popupId === n.replacesId) {
                            root.popups.set(i, {
                                popupId: n.id,
                                app:     n.appName || "",
                                summary: n.summary || "",
                                body:    n.body    || "",
                                icon:    n.appIcon || "",
                                urgency: urgency,
                                timeout: timeoutMs
                            })
                            root.popupReplaced(n.replacesId, n.id)
                            replaceInCenter(n)
                            return
                        }
                    }
                }

                // New popup — newest on top, cap stack at 5
                root.popups.insert(0, {
                    popupId: n.id,
                    app:     n.appName || "",
                    summary: n.summary || "",
                    body:    n.body    || "",
                    icon:    n.appIcon || "",
                    urgency: urgency,
                    timeout: timeoutMs
                })
                while (root.popups.count > 5)
                    root.popups.remove(root.popups.count - 1, 1)

                addToCenter(n)

            } catch(e) {
                console.warn("NotificationServer onNotification error:", e)
                // Fallback: at minimum get it into the dashboard center
                root.notifications.insert(0, {
                    notifId: n.id  || 0,
                    app:     n.appName || "",
                    summary: n.summary || "",
                    body:    n.body    || "",
                    time:    Qt.formatDateTime(new Date(), "HH:mm")
                })
                while (root.notifications.count > 50)
                    root.notifications.remove(root.notifications.count - 1, 1)
            }
        }
    }

    function replaceInCenter(n) {
        for (let i = 0; i < root.notifications.count; i++) {
            if (root.notifications.get(i).notifId === n.replacesId) {
                root.notifications.set(i, {
                    notifId: n.id,
                    app:     n.appName || "",
                    summary: n.summary || "",
                    body:    n.body    || "",
                    time:    Qt.formatDateTime(new Date(), "HH:mm")
                })
                return
            }
        }
        addToCenter(n)
    }

    function addToCenter(n) {
        root.notifications.insert(0, {
            notifId: n.id,
            app:     n.appName || "",
            summary: n.summary || "",
            body:    n.body    || "",
            time:    Qt.formatDateTime(new Date(), "HH:mm")
        })
        while (root.notifications.count > 50)
            root.notifications.remove(root.notifications.count - 1, 1)
    }
}
