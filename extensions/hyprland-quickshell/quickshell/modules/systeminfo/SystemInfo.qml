// modules/systeminfo/SystemInfo.qml  — BACKEND + MODULE DESCRIPTOR
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.globals

QtObject {
    id: root // Using an ID is much safer than calling 'SystemInfo' inside its own file

    readonly property string moduleType: "dynamic"

    readonly property var items: {
        let out = [
            {
                icon:      "󰍛",
                label:     root.cpuPercent + "%",
                bgColor:   Colors.color0,
                onClicked: function() { root.openMonitor() }
            },
            {
                icon:      "󰾆",
                label:     root.memPercent + "%",
                bgColor:   Colors.color0,
                onClicked: function() { root.openMonitor() }
            }
        ]
        if (root.gpuText !== "")
            out.push({
                icon:      "󰢮",
                label:     root.gpuText,
                bgColor:   Colors.color0,
                onClicked: function() { root.openMonitor() }
            })
        return out
    }

    property int    cpuPercent: 0
    property int    memPercent: 0
    property string gpuText:    ""
    property int _prevIdle:  0
    property int _prevTotal: 0

    function openMonitor() {
        Quickshell.execDetached({ command: ["bash", "-c", "kitty -e btop"] })
    }

    property var _sysProc: Process {
        id: sysProc
        command: ["bash", "-c", "cat /proc/stat | head -1; echo '---'; cat /proc/meminfo"]
        property string _buf: ""
        stdout: SplitParser { onRead: (l) => { sysProc._buf += l + "\n" } }
        onExited: {
            let sections = _buf.split("---\n")
            if (sections[0]) {
                let parts = sections[0].trim().split(/\s+/).slice(1).map(Number)
                let idle  = parts[3] + (parts[4] || 0)
                let total = parts.reduce((a, b) => a + b, 0)
                let dI = idle - root._prevIdle, dT = total - root._prevTotal
                root.cpuPercent = dT > 0 ? Math.round((1 - dI / dT) * 100) : 0
                root._prevIdle = idle; root._prevTotal = total
            }
            if (sections[1]) {
                let lines = sections[1].split("\n")
                let val = (k) => { let l = lines.find(l => l.startsWith(k)); return l ? parseInt(l.split(/\s+/)[1]) : 0 }
                let tot = val("MemTotal:"), free = val("MemFree:"), buf = val("Buffers:"), cac = val("Cached:")
                root.memPercent = tot > 0 ? Math.round((tot - free - buf - cac) / tot * 100) : 0
            }
            _buf = ""
        }
    }

    property var _gpuProc: Process {
        id: gpuProc
        
        // Inlined bash script with string concatenation for readability
        // Note the escaped quotes around \"°C\" so QML doesn't break
        command: [
            "bash", 
            "-c", 
            "if command -v nvidia-smi > /dev/null 2>&1; then " +
                "nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits | awk '{print $1\"°C\"}'; " +
            "elif sensors | grep -q 'amdgpu'; then " +
                "sensors | grep -E 'edge|junction' | head -n 1 | awk '{print $2}' | tr -d '+'; " +
            "else " +
                "sensors | grep 'Package id 0' | awk '{print $4}' | tr -d '+'; " +
            "fi"
        ]
        
        property string _buf: ""
        
        stdout: SplitParser { 
            onRead: (l) => { 
                if (gpuProc._buf === "") gpuProc._buf = l.trim() 
            } 
        }
        
        onExited: { 
            root.gpuText = _buf; 
            _buf = "" 
        }
    }

    property var _sysTimer: Timer { interval: 1000; running: true; repeat: true; onTriggered: sysProc.running = true }
    // Increased the GPU polling to 2 seconds (2000ms). Polling nvidia-smi every 1 second can sometimes cause micro-stutters.
    property var _gpuTimer: Timer { interval: 1000; running: true; repeat: true; onTriggered: gpuProc.running = true }
    
    Component.onCompleted: { sysProc.running = true; gpuProc.running = true }
}