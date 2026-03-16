// modules/status/Status.qml  — BACKEND + MODULE DESCRIPTOR
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.globals

QtObject {
    readonly property string moduleType: "dynamic"

    // Status exposes multiple optional chips — battery and/or backlight
    // Each is only included in items if the hardware is present
    readonly property var items: {
        let out = []
        if (Status.hasBattery)
            out.push({
                icon:    Status.battIcon,
                label:   Status.battPercent + "%",
                bgColor: Status.battLow ? Colors.color1 : Colors.color0
            })
        if (Status.hasBacklight)
            out.push({
                icon:      Status.blIcon,
                label:     Status.blPercent + "%",
                bgColor:   Colors.color0,
                onScrolled: function(d) { Status.stepBacklight(d) }
            })
        return out
    }

    // ── Battery ───────────────────────────────────────────────────────────
    property int    battPercent: 0
    property string battStatus:  "Unknown"
    property bool   hasBattery:  false
    readonly property string battIcon: {
        if (battStatus === "Charging" || battStatus === "Full") return "󱐋"
        let p = battPercent
        if (p > 80) return ""
        if (p > 60) return ""
        if (p > 40) return ""
        if (p > 20) return ""
        return ""
    }
    readonly property bool battLow: battPercent <= 15 && battStatus !== "Charging"

    // ── Backlight ─────────────────────────────────────────────────────────
    property int  blMax:        100
    property int  blCurrent:    100
    property bool hasBacklight: false
    readonly property int    blPercent: blMax > 0 ? Math.round(blCurrent / blMax * 100) : 0
    readonly property string blIcon: {
        let p = blPercent
        if (p > 87) return "󰛨"
        if (p > 62) return ""
        if (p > 37) return ""
        if (p > 12) return ""
        return ""
    }
    function setBacklight(v) {
        let next = Math.max(1, Math.min(blMax, v))
        Quickshell.execDetached({ command: ["/bin/bash", "-c",
            "echo " + next + " > /sys/class/backlight/intel_backlight/brightness"] })
        blCurrent = next
    }
    function stepBacklight(d) { setBacklight(blCurrent + Math.round(blMax * 0.05) * d) }

    // ── Polling ───────────────────────────────────────────────────────────
    property var _batProc: Process {
        id: batProc
        command: ["/bin/bash", "-c",
            "cap=$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null); " +
            "sta=$(cat /sys/class/power_supply/BAT0/status   2>/dev/null); " +
            "[ -n \"$cap\" ] && echo \"$cap $sta\""]
        property string _buf: ""
        stdout: SplitParser { onRead: (l) => { batProc._buf = l.trim() } }
        onExited: {
            let parts = _buf.split(" ")
            if (parts[0] !== "") {
                Status.battPercent = parseInt(parts[0]) || 0
                Status.battStatus  = parts[1] || "Unknown"
                Status.hasBattery  = true
            }
            _buf = ""
        }
    }
    property var _blProc: Process {
        id: blProc
        command: ["/bin/bash", "-c",
            "max=$(cat /sys/class/backlight/intel_backlight/max_brightness 2>/dev/null); " +
            "cur=$(cat /sys/class/backlight/intel_backlight/brightness     2>/dev/null); " +
            "[ -n \"$max\" ] && echo \"$max $cur\""]
        property string _buf: ""
        stdout: SplitParser { onRead: (l) => { blProc._buf = l.trim() } }
        onExited: {
            let parts = _buf.split(" ")
            if (parts[0] !== "") {
                Status.blMax        = parseInt(parts[0]) || 100
                Status.blCurrent    = parseInt(parts[1]) || 100
                Status.hasBacklight = true
            }
            _buf = ""
        }
    }
    property var _batTimer: Timer { interval: 30000; running: true; repeat: true; onTriggered: batProc.running = true }
    property var _blTimer:  Timer { interval: 2000;  running: true; repeat: true; onTriggered: blProc.running  = true }
    Component.onCompleted: { batProc.running = true; blProc.running = true }
}
