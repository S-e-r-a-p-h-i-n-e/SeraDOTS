// shell.qml — entry point
//@ pragma UseQApplication
import Quickshell
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
