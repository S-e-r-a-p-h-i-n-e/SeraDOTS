// modules/updates/Updates.qml  — BACKEND + MODULE DESCRIPTOR
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.globals

QtObject {
    readonly property string moduleType: "dynamic"

    // Only surfaces when there are actually updates — empty array hides the chip
    readonly property var items: Updates.hasUpdates ? [
    {
        icon:      "󰚰",
        label:     Updates.updateCount + "",
        bgColor:   Colors.Background,
        onClicked: function() { Updates.update() }
    }
] : []

    property int updateCount: 0
    readonly property bool hasUpdates: updateCount > 0

    function update() {
        Quickshell.execDetached({ command: ["/bin/bash", "-l", "-c", "kitty -e topgrade"] })
    }

    property var _proc: Process {
        id: updateProc
        command: ["/bin/bash", "-c", "checkupdates 2>/dev/null | wc -l"]
        property string _buf: ""
        stdout: SplitParser { onRead: (l) => { updateProc._buf = l.trim() } }
        onExited: { Updates.updateCount = parseInt(_buf) || 0; _buf = "" }
    }
    property var _timer: Timer { interval: 7200000; running: true; repeat: true; onTriggered: updateProc.running = true }
    Component.onCompleted: updateProc.running = true
}
