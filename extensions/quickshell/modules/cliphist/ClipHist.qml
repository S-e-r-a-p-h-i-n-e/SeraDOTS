// modules/cliphist/ClipHist.qml  — BACKEND + MODULE DESCRIPTOR
pragma Singleton

import QtQuick
import Quickshell
import qs.globals

QtObject {
    readonly property string moduleType: "static"

    readonly property var item: ({
        icon:      "󱘔",
        onClicked: function() { ClipHist.open() }
    })

    function open() {
        Quickshell.execDetached({ command: ["sh", "-c",
            "qs ipc call clipboard toggle"] })
    }
}
