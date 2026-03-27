// modules/power/Power.qml  — BACKEND + MODULE DESCRIPTOR
pragma Singleton

import QtQuick
import Quickshell
import qs.globals

QtObject {
    readonly property string moduleType: "static"

    readonly property var item: ({
        icon:      "⏻",
        onClicked: function() { EventBus.togglePanel("power", null) }
    })
}
