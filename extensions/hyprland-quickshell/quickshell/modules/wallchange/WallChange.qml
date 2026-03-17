// modules/wallchange/WallChange.qml  — BACKEND + MODULE DESCRIPTOR
pragma Singleton

import QtQuick
import Quickshell
import qs.globals

QtObject {
    readonly property string moduleType: "static"

    readonly property var item: ({
        icon:      "󰸉",
        onClicked: function() { WallChange.open() }
    })

    function open() {
        Quickshell.execDetached({ command: ["sh", "-c",
            "wallchange.sh"] })
    }
}
