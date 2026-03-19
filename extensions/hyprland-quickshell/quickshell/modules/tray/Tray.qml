// modules/tray/Tray.qml — BACKEND ONLY
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import qs.globals

QtObject {
    readonly property string moduleType: "custom"
    readonly property var    items:      SystemTray.items.values

    // Delegates to globals/Icons.qml — single source of truth for all app icons.
    function iconFor(item) { return Icons.getIconFromItem(item) }
}
