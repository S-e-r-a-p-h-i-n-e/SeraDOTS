// globals/EventBus.qml
pragma Singleton

import QtQuick
import Quickshell

QtObject {
    // Panel visibility — screen is the QtObject screen handle from Quickshell.screens
    signal togglePanel(string panelId, var screen)

    // Bar configuration
    signal changeLocation(string newLocation)
    signal toggleBorders(bool state)
    signal toggleTransparentNavbar(bool state)
    signal changeLayout(string layoutName)
}
