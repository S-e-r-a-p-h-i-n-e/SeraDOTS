// modules/settings/Settings.qml  — BACKEND + MODULE DESCRIPTOR
// Also absorbs LayoutSwitcher — both opened the same "theming" panel
pragma Singleton

import QtQuick
import qs.globals

QtObject {
    readonly property string moduleType: "static"

    readonly property var item: ({
        icon:      "",
        onClicked: function(screen) { SettingsModule.open(screen) }
    })

    function open(screen) { EventBus.togglePanel("theming", screen) }
}
