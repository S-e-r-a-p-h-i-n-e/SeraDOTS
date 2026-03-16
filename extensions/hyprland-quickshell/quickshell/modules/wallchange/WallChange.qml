// modules/wallchange/WallChange.qml  — BACKEND + MODULE DESCRIPTOR
pragma Singleton

import QtQuick
import Quickshell
import qs.globals

QtObject {
    readonly property string moduleType: "static"

    readonly property var item: ({
        icon:      "󰸉",
        onClicked: function() { WallChange.change() }
    })

    function change() {
        Quickshell.execDetached({ command: ["bash", "-c", "wallchange.sh"] })
    }
}
