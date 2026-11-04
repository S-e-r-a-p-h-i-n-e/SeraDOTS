// components/Panel/Panel.qml
// Panel container — windowing, positioning, and animation orchestration.
// Visual content is delegated to PanelBackground and PanelFillets.
import Quickshell
import Quickshell.Wayland
import QtQuick
import qs.globals
import qs.components

Scope {
    id: rootScope

    property bool   showPanel:       false
    property string panelId:         ""
    property var    targetScreen:    null
    property real   panelWidth:      Style.panelWidth
    property real   panelHeight:     Style.panelHeight
    property real   navbarOffset:    0
    property real   visualGap:       0
    property int    keyboardFocus:   WlrKeyboardFocus.OnDemand
    property string animationPreset: "slide"

    readonly property real   tensionRadius: 20
    readonly property real   panelRadius:   Style.panelRadius
    readonly property bool   isHorizontal:  Config.isHorizontal
    readonly property string barEdge:       Config.navbarLocation

    readonly property real maxSlidePx:   isHorizontal ? panelHeight : panelWidth
    readonly property real exposedPx:    maxSlidePx * (typeof animator !== "undefined" ? animator.animProgress : 0)
    readonly property real filletOffset: animationPreset === "slide"
        ? Math.max(0, panelRadius - exposedPx + 8)
        : 0

    default property Component panelContent

    Variants {
        // Delay until Config is loaded so layer-shell anchors are correct on creation.
        // navbarLocation is embedded in the model key so Variants recreates windows
        // when the bar edge changes — layer-shell anchors are immutable after creation.
        model: Config.loaded
            ? Quickshell.screens.map(s => s.name + "|" + Config.navbarLocation)
            : []

        // ── Dismiss overlay ────────────────────────────────────────────────
        // Full-screen transparent window for catching outside clicks.
        PanelWindow {
            required property var modelData
            readonly property string screenName: modelData.split("|")[0]
            readonly property var    realScreen:  Quickshell.screens.find(s => s.name === screenName) ?? null
            screen: realScreen

            visible: rootScope.showPanel && rootScope.panelId !== "" && realScreen !== null &&
                     (!rootScope.targetScreen || rootScope.targetScreen.name === screenName)
            color:   "transparent"

            WlrLayershell.layer:         WlrLayer.Top
            exclusionMode:               ExclusionMode.Ignore
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
            WlrLayershell.namespace:     "quickshell-panel-dismiss"

            anchors { top: true; bottom: true; left: true; right: true }

            MouseArea {
                anchors.fill: parent
                onClicked:    EventBus.togglePanel(rootScope.panelId, null)
                hoverEnabled: false
                enabled:      !animator.isAnimating
            }
        }

        // ── Panel content window ───────────────────────────────────────────
        PanelWindow {
            required property var modelData
            readonly property string screenName: modelData.split("|")[0]
            readonly property var    realScreen:  Quickshell.screens.find(s => s.name === screenName) ?? null
            screen: realScreen

            readonly property bool isTargetScreen: realScreen !== null &&
                (!rootScope.targetScreen || rootScope.targetScreen.name === screenName)

            visible: animator.isSurfaceVisible && isTargetScreen
            color:   "transparent"

            WlrLayershell.layer:         WlrLayer.Top
            exclusionMode:               ExclusionMode.Ignore
            WlrLayershell.keyboardFocus: rootScope.keyboardFocus
            WlrLayershell.namespace:     "quickshell-panel"

            Shortcut {
                sequence: "Escape"
                onActivated: {
                    if (rootScope.showPanel && !animator.isAnimating)
                        EventBus.togglePanel(rootScope.panelId, null)
                }
            }

            anchors {
                top:    Config.navbarLocation === "top"
                bottom: Config.navbarLocation === "bottom"
                left:   Config.navbarLocation === "left"
                right:  Config.navbarLocation === "right"
            }

            margins {
                top:    Config.navbarLocation === "top"    ? (rootScope.navbarOffset + rootScope.visualGap) : 0
                bottom: Config.navbarLocation === "bottom" ? (rootScope.navbarOffset + rootScope.visualGap) : 0
                left:   Config.navbarLocation === "left"   ? (rootScope.navbarOffset + rootScope.visualGap) : 0
                right:  Config.navbarLocation === "right"  ? (rootScope.navbarOffset + rootScope.visualGap) : 0
            }

            implicitWidth:  rootScope.isHorizontal
                ? rootScope.panelWidth + (rootScope.tensionRadius * 2)
                : rootScope.panelWidth
            implicitHeight: !rootScope.isHorizontal
                ? rootScope.panelHeight + (rootScope.tensionRadius * 2)
                : rootScope.panelHeight

            AnimatedElement {
                id:           animator
                anchors.fill: parent
                show:         rootScope.showPanel && isTargetScreen
                preset:       rootScope.animationPreset
                edge:         rootScope.barEdge

                PanelBackground {
                    anchors.fill:    parent
                    panelWidth:      rootScope.panelWidth
                    panelHeight:     rootScope.panelHeight
                    panelRadius:     rootScope.panelRadius
                    tensionRadius:   rootScope.tensionRadius
                    navbarLocation:  Config.navbarLocation
                    isHorizontal:    rootScope.isHorizontal
                    animationPreset: rootScope.animationPreset
                    isAnimating:     animator.isAnimating
                    panelContent:    rootScope.panelContent
                }
            }
        }
    }
}
