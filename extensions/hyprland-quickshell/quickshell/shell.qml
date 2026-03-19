// shell.qml — entry point
//@ pragma UseQApplication
import Quickshell
import Quickshell.Io
import QtQuick
import qs.globals
import qs.components
import qs.engine
import qs.panels
import qs.modules.audio
import qs.modules.cava
import qs.modules.cliphist
import qs.modules.clock
import qs.modules.idleinhibitor
import qs.modules.media
import qs.modules.network
import qs.modules.notifications
import qs.modules.power
import qs.modules.settings
import qs.modules.status
import qs.modules.systeminfo
import qs.modules.tray
import qs.modules.updates
import qs.modules.wallchange
import qs.modules.workspaces

Scope {
    id: shell

    // The cross-compositor IPC listener
    IpcHandler {
        target: "launcher"

        // Explicit type annotations (: void) are REQUIRED for Quickshell IPC!
        function toggle(): void {
            EventBus.togglePanel("launcher", null)
        }

        function close(): void {
            if (shell.activePanel === "launcher") {
                EventBus.togglePanel("launcher", null)
            }
        }
    }

    IpcHandler {
        target: "clipboard"
        function toggle(): void { EventBus.togglePanel("clipboard", null) }
        function close(): void {
            if (shell.activePanel === "clipboard") {
                EventBus.togglePanel("clipboard", null)
            }
        }
    }

    IpcHandler {
        target: "wallpaper"
        function toggle(): void { EventBus.togglePanel("wallpaper", null) }
        function close(): void {
            if (shell.activePanel === "wallpaper") {
                EventBus.togglePanel("wallpaper", null)
            }
        }
    }

    IpcHandler {
        target: "theming"
        function toggle(): void { EventBus.togglePanel("theming", null) }
        function close(): void {
            if (shell.activePanel === "theming") {
                EventBus.togglePanel("theming", null)
            }
        }
    }

    IpcHandler {
        target: "emoji"
        function toggle(): void { EventBus.togglePanel("emoji", null) }
        function close(): void  {
            if (shell.activePanel === "emoji") {
                EventBus.togglePanel("emoji", null)
            }
        }
    }

    // Extend Qt's icon search paths to match what GTK/Waybar searches automatically.
    Component.onCompleted: {
        let extra = [
            "/usr/share/pixmaps",
            Qt.resolvedUrl("file://" + Quickshell.env("HOME") + "/.local/share/icons"),
            Qt.resolvedUrl("file://" + Quickshell.env("HOME") + "/.icons"),
        ]
        for (let p of extra) {
            if (!(Qt.iconSearchPaths ?? []).includes(p))
                Qt.iconSearchPaths = (Qt.iconSearchPaths ?? []).concat([p])
        }
    }

    // ── Wallpaper — self-contained, handles its own Variants internally ──

    LayoutLoader { id: loader }

    ScreenBorder {
        enabled:      Config.enableBorders && !Config.transparentNavbar
        location:     Config.navbarLocation
        borderColor:  Colors.background
        borderWidth:  Style.borderWidth
        cornerRadius: Style.cornerRadius
    }

    property string activePanel: ""
    property var    activeScreen: null

    Launcher {
        showPanel:    shell.activePanel === "launcher"
        targetScreen: shell.activeScreen
        navbarOffset: loader.barSize
        panelId:      "launcher"
    }

    ClipManager {
        showPanel:    shell.activePanel === "clipboard"
        targetScreen: shell.activeScreen
        navbarOffset: loader.barSize
    }

    Wallpaper {
        showPanel:    shell.activePanel === "wallpaper"
        targetScreen: shell.activeScreen
        navbarOffset: loader.barSize
    }

    EmojiPicker {
        showPanel:    shell.activePanel === "emoji"
        targetScreen: shell.activeScreen
        navbarOffset: loader.barSize
    }

    Dashboard {
        showPanel:    shell.activePanel === "dashboard"
        targetScreen: shell.activeScreen
        panelId:      "dashboard"
        navbarOffset: loader.barSize
    }

    Settings {
        showPanel:      shell.activePanel === "theming"
        targetScreen:   shell.activeScreen
        panelId:        "theming"
        navbarOffset:   loader.barSize
        bordersEnabled: Config.enableBorders
    }

    AdvancedSettings {
        showPanel:    shell.activePanel === "advanced"
        targetScreen: shell.activeScreen
        panelId:      "advanced"
        navbarOffset: loader.barSize
    }

    PowerManager {
        showPanel:    shell.activePanel === "power"
        targetScreen: shell.activeScreen
    }

    // Always-on popup layer — manages its own visibility per notification
    // Pending location change — held until the exit animation completes
    property string pendingLocation: ""

    Timer {
        id: locationChangeTimer
        // Animations.normal (275ms) + small buffer for the window to settle
        interval: 300
        onTriggered: {
            Config.saveSetting("navbarLocation", shell.pendingLocation)
            // Reopen the panel from the new edge after windows have recreated
            reopenTimer.restart()
        }
    }

    Timer {
        id: reopenTimer
        interval: 50
        onTriggered: {
            if (shell.pendingLocation !== "") {
                shell.activePanel = "theming"
                shell.pendingLocation = ""
            }
        }
    }

    NotificationPopups {}

    Connections {
        target: EventBus

        function onTogglePanel(panelId, screen) {
            if (shell.activePanel === panelId) {
                shell.activePanel = ""
                shell.activeScreen = null
            } else {
                shell.activePanel = panelId
                shell.activeScreen = screen
            }
        }
        function onChangeLocation(newLocation) {
            if (shell.activePanel !== "") {
                // Close the panel, wait for exit animation, then change location
                shell.pendingLocation = newLocation
                shell.activePanel = ""
                shell.activeScreen = null
                locationChangeTimer.restart()
            } else {
                Config.saveSetting("navbarLocation", newLocation)
            }
        }
        function onToggleBorders(state) {
            Config.saveSetting("enableBorders", state)
        }
        function onToggleTransparentNavbar(state) {
            Config.saveSetting("transparentNavbar", state)
        }
        function onChangeLayout(layoutName) {
            Config.saveSetting("activeLayout", layoutName)
        }
    }
}
