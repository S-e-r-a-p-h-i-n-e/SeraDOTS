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
            EventBus.togglePanel("launcher", null) // <-- Added null here
        }

        // You can easily add more commands here later!
        function close(): void {
            if (shell.activePanel === "launcher") {
                EventBus.togglePanel("launcher", null) // <-- And added null here
            }
        }
    }

    IpcHandler {
        target: "clipboard"

        // Explicit type annotations (: void) are REQUIRED for Quickshell IPC!
        function toggle(): void {
            EventBus.togglePanel("clipboard", null) // <-- Added null here
        }

        // You can easily add more commands here later!
        function close(): void {
            if (shell.activePanel === "clipboard") {
                EventBus.togglePanel("clipboard", null) // <-- And added null here
            }
        }
    }

    IpcHandler {
        target: "wallpaper"

        // Explicit type annotations (: void) are REQUIRED for Quickshell IPC!
        function toggle(): void {
            EventBus.togglePanel("wallpaper", null) // <-- Added null here
        }

        // You can easily add more commands here later!
        function close(): void {
            if (shell.activePanel === "wallpaper") {
                EventBus.togglePanel("wallpaper", null) // <-- And added null here
            }
        }
    }

    // Extend Qt's icon search paths to match what GTK/Waybar searches automatically.
    // Qt's image://icon/ provider only searches theme paths it knows at startup —
    // this adds pixmaps and user-local icon dirs so AUR packages resolve correctly.
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
            Config.saveSetting("navbarLocation", newLocation)
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
