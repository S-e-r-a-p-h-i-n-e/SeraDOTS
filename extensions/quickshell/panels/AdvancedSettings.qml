// panels/AdvancedSettings.qml
import QtQuick
import Quickshell
import QtQuick.Controls
import qs.components
import qs.globals

Panel {
    id: advPanel

    // ── Tab state ─────────────────────────────────────────────────────────
    property int activeTab: 1   // 0 = Back to Settings 1 = Navbar, 2 = Panels

    Column {
        anchors.fill: parent
        spacing: 0

        // ── Header ────────────────────────────────────────────────────────
        Text {
            id: advHeader
            text:           "󰒓  Advanced Settings"
            color:          Colors.foreground
            font.family:    Style.barFont
            font.pixelSize: 18
            font.weight:    Font.ExtraBold
            anchors.horizontalCenter: parent.horizontalCenter
            bottomPadding:  12
        }

        // ── Tab bar ───────────────────────────────────────────────────────
        Item {
            id: advTabBar
            width:  parent.width
            height: 36

            Row {
                anchors.centerIn: parent
                spacing: 8

                Repeater {
                    model: ["Settings", "Navbar", "Panels"]
                    delegate: Rectangle {
                        required property string modelData
                        required property int    index

                        width:  100
                        height: 30
                        radius: 15
                        color:  advPanel.activeTab === index ? Colors.color7 : Colors.color0
                        Behavior on color { ColorAnimation { duration: 150 } }

                        Text {
                            anchors.centerIn: parent
                            text:        parent.modelData
                            color:       advPanel.activeTab === parent.index ? Colors.background : Colors.foreground
                            font.family: Style.barFont
                            font.pixelSize: 12
                            font.weight: Font.Bold
                            Behavior on color { ColorAnimation { duration: 150 } }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape:  Qt.PointingHandCursor
                            onClicked:    {
                                if (index === 0) {
                                    // Trigger navigation immediately on index 0 click
                                    EventBus.togglePanel("advanced", advPanel.targetScreen)
                                    EventBus.togglePanel("theming", advPanel.targetScreen)
                                } else {
                                    // Otherwise, update the view state normally
                                    advPanel.activeTab = index
                                }
                            }
                        }
                    }
                }
            }
        }

        Rectangle { id: advDivider; width: parent.width; height: 1; color: Colors.color8; opacity: 0.5 }

        // ── Scrollable content ────────────────────────────────────────────
        ScrollView {
            id: scroll
            width:  parent.width
            height: parent.height - advHeader.implicitHeight - advTabBar.height - advDivider.height
            clip:   true

            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded
                contentItem: Rectangle {
                    implicitWidth: 4
                    radius:        2
                    color:         Colors.color7
                    opacity:       0.5
                }
            }

            // Loader swaps content between tabs — only one Column exists at
            // a time so ScrollView always gets the correct content height.
            Loader {
                width:           scroll.width
                sourceComponent: advPanel.activeTab === 1 ? advPanel.navbarTabComp : advPanel.panelsTabComp
            }
        }
    }

    // ── Tab content components ────────────────────────────────────────────
    property Component navbarTabComp: Column {
        width:      parent ? parent.width : 0 // FIX: Safely inherit the Loader's width
        spacing:    0

        Section { label: "Bar" }
        // FIX 2: Use the magically exposed 'newValue' variable directly
        Field { label: "Bar Size";      value: Style.barSize;      onCommitted: Style.saveSetting("barSize", newValue) }
        Field { label: "Module Size";   value: Style.moduleSize;   onCommitted: Style.saveSetting("moduleSize", newValue) }
        Field { label: "Bar Padding";   value: Style.barPadding;   onCommitted: Style.saveSetting("barPadding", newValue) }
        Field { label: "Bar Font";      value: Style.barFont;      isText: true;        isLast: true;       onCommitted: Style.saveSetting("barFont", newValue) }

        Section { label: "Slots" }
        Field { label: "Slot Spacing";  value: Style.slotSpacing;  isLast: true;  onCommitted: Style.saveSetting("slotSpacing", newValue) }

        Section { label: "Pills" }
        Field { label: "Pill Padding";  value: Style.pillPadding;  onCommitted: Style.saveSetting("pillPadding", newValue) }
        Field { label: "Pill Spacing";  value: Style.pillSpacing;  onCommitted: Style.saveSetting("pillSpacing", newValue) }
        Field { label: "Pill Opacity";  value: Style.pillOpacity;  isDecimal: true; onCommitted: Style.saveSetting("pillOpacity", newValue) }
        Field { label: "Pill Radius";   value: Style.pillRadius;  isLast: true;  onCommitted: Style.saveSetting("pillRadius", newValue) }

        Section { label: "Chips" }
        Field { label: "Chip Spacing";       value: Style.chipSpacing;      onCommitted: Style.saveSetting("chipSpacing", newValue) }
        Field { label: "Chip Inner Spacing"; value: Style.chipInnerSpacing; isLast: true; onCommitted: Style.saveSetting("chipInnerSpacing", newValue) }

        Section { label: "Borders" }
        Field { label: "Border Width";  value: Style.borderWidth;  disabled: Config.transparentNavbar; onCommitted: Style.saveSetting("borderWidth", newValue) }
        Field { label: "Corner Radius"; value: Style.cornerRadius; disabled: Config.transparentNavbar; isLast: true; onCommitted: Style.saveSetting("cornerRadius", newValue) }

        Item { width: 1; height: 12 }
    }

    property Component panelsTabComp: Column {
        width:      parent ? parent.width : 0 // FIX: Safely inherit the Loader's width
        spacing:    0
        topPadding: 12

        Section { label: "Size" }
        Field { label: "Panel Width";   value: Style.panelWidth;   onCommitted: Style.saveSetting("panelWidth", newValue) }
        Field { label: "Panel Height";  value: Style.panelHeight;  isLast: true;  onCommitted: Style.saveSetting("panelHeight", newValue) }

        Section { label: "Shape" }
        Field { label: "Panel Radius";  value: Style.panelRadius;  onCommitted: Style.saveSetting("panelRadius", newValue) }
        Field { label: "Panel Padding"; value: Style.panelPadding; isLast: true; onCommitted: Style.saveSetting("panelPadding", newValue) }

        Item { width: 1; height: 12 }
    }
}
