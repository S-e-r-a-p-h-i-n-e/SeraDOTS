// components/Panel.qml
import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Shapes
import qs.globals

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

    readonly property real tensionRadius: 20
    readonly property real panelRadius:   Style.panelRadius
    readonly property bool isHorizontal:  Config.isHorizontal

    // The bar edge the panel slides in from — drives AnimatedElement.edge
    readonly property string barEdge: Config.navbarLocation

    default property Component panelContent

    // Fillet offset — how far the tension corner shapes lead the panel edge
    // during the slide-in. Driven by AnimatedElement's exposed animProgress.
    readonly property real maxSlidePx:   isHorizontal ? panelHeight : panelWidth
    readonly property real exposedPx:    maxSlidePx * (typeof animator !== "undefined" ? animator.animProgress : 0)
    readonly property real filletOffset: animationPreset === "slide"
        ? Math.max(0, panelRadius - exposedPx + 8)
        : 0

    Variants {
        // Do not instantiate PanelWindows until the config file has been
        // read. Wayland layer-shell anchors are fixed at window-creation
        // time, so creating a window while navbarLocation still holds the
        // hardcoded default ("top") would permanently mis-anchor the panel
        // when the user has a side navbar saved.
        model: Config.loaded ? Quickshell.screens : null

        // ── Dismiss overlay ───────────────────────────────────────────────
        // Full-screen transparent window just for catching outside clicks.
        // Kept separate so the blur window can be sized exactly to the panel.
        PanelWindow {
            required property var modelData
            screen: modelData

            visible: rootScope.showPanel && rootScope.panelId !== "" &&
                     (!rootScope.targetScreen || rootScope.targetScreen.name === modelData.name)
            color:   "transparent"

            WlrLayershell.layer:         WlrLayer.Top
            exclusionMode:               ExclusionMode.Ignore
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
            WlrLayershell.namespace:     "quickshell-panel-dismiss"

            anchors { top: true; bottom: true; left: true; right: true }

            MouseArea {
                anchors.fill: parent
                onClicked:    EventBus.togglePanel(rootScope.panelId)
                hoverEnabled: false
            }
        }

        // ── Panel content window ──────────────────────────────────────────
        // Sized exactly to the panel so Hyprland's blur is confined to it.
        PanelWindow {
            required property var modelData
            screen: modelData

            readonly property bool isTargetScreen: !rootScope.targetScreen || rootScope.targetScreen.name === modelData.name

            // Stay alive while AnimatedElement is still fading out
            visible: animator.isSurfaceVisible && isTargetScreen
            color:   "transparent"

            WlrLayershell.layer:         WlrLayer.Top
            exclusionMode:               ExclusionMode.Ignore
            WlrLayershell.keyboardFocus: rootScope.keyboardFocus
            WlrLayershell.namespace:     "quickshell-panel"

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

            // Sized exactly to the panel — no excess surface for blur to spill onto.
            implicitWidth:  rootScope.isHorizontal
                ? rootScope.panelWidth + (rootScope.tensionRadius * 2)
                : rootScope.panelWidth
            implicitHeight: !rootScope.isHorizontal
                ? rootScope.panelHeight + (rootScope.tensionRadius * 2)
                : rootScope.panelHeight

            // ── AnimatedElement ───────────────────────────────────────────
            // All show/hide animation lives here — Panel.qml just flips
            // animator.show and everything else follows.
            AnimatedElement {
                id: animator
                anchors.fill: parent

                // Only animate on the target screen so isSurfaceVisible
                // doesn't stay true on non-target screens
                show:   rootScope.showPanel && isTargetScreen
                preset: rootScope.animationPreset
                edge:   rootScope.barEdge

                // ── Panel background ──────────────────────────────────────
                Rectangle {
                    id: bg
                    color:        Config.transparentNavbar
                                  ? Qt.rgba(Colors.background.r, Colors.background.g, Colors.background.b, 0.01)
                                  : Colors.background
                    radius:       rootScope.panelRadius
                    border.width: Config.transparentNavbar ? 1 : 0
                    border.color: Config.transparentNavbar ? Qt.rgba(1, 1, 1, 0.15) : "transparent"

                    Behavior on color        { ColorAnimation  { duration: Animations.normal; easing.type: Animations.easeInOut } }
                    Behavior on border.color { ColorAnimation  { duration: Animations.normal; easing.type: Animations.easeInOut } }
                    Behavior on border.width { NumberAnimation { duration: Animations.normal; easing.type: Animations.easeInOut } }

                    anchors {
                        fill:         parent
                        topMargin:    (!Config.transparentNavbar && Config.navbarLocation === "top")    ? -radius : 0
                        bottomMargin: (!Config.transparentNavbar && Config.navbarLocation === "bottom") ? -radius : 0
                        leftMargin:   (!Config.transparentNavbar && Config.navbarLocation === "left")   ? -radius : 0
                        rightMargin:  (!Config.transparentNavbar && Config.navbarLocation === "right")  ? -radius : 0
                    }

                    Behavior on anchors.topMargin    { NumberAnimation { duration: Animations.normal; easing.type: Animations.easeInOut } }
                    Behavior on anchors.bottomMargin { NumberAnimation { duration: Animations.normal; easing.type: Animations.easeInOut } }
                    Behavior on anchors.leftMargin   { NumberAnimation { duration: Animations.normal; easing.type: Animations.easeInOut } }
                    Behavior on anchors.rightMargin  { NumberAnimation { duration: Animations.normal; easing.type: Animations.easeInOut } }
                }

                // ── Panel content ─────────────────────────────────────────
                Item {
                    anchors.fill:    parent
                    anchors.margins: Style.panelPadding
                    clip: true

                    Loader {
                        anchors.fill:    parent
                        sourceComponent: rootScope.panelContent
                    }
                }

                // ── Tension fillets ───────────────────────────────────────
                // Keep bar/panel corner join seamless during slide-in.
                // Hidden in transparent mode since there's no solid bar to blend into.
                Item {
                    anchors.fill: parent
                    visible:      rootScope.animationPreset === "slide"
                    opacity:      Config.transparentNavbar ? 0.0 : 1.0
                    Behavior on opacity { NumberAnimation { duration: Animations.normal; easing.type: Animations.easeInOut } }

                    transform: Translate {
                        x: Config.navbarLocation === "left"  ? -rootScope.filletOffset
                         : Config.navbarLocation === "right" ?  rootScope.filletOffset : 0
                        y: Config.navbarLocation === "top"   ? -rootScope.filletOffset
                         : Config.navbarLocation === "bottom"?  rootScope.filletOffset : 0
                    }

                    // ── top ──────────────────────────────────────────────────
                    Item {
                        visible: Config.navbarLocation === "top"
                        anchors.fill: parent
                        Shape {
                            anchors { left: parent.left; top: parent.top }
                            width: rootScope.tensionRadius; height: rootScope.tensionRadius
                            ShapePath {
                                fillColor: Colors.background; strokeWidth: 0
                                startX: rootScope.tensionRadius; startY: rootScope.tensionRadius
                                PathLine { x: rootScope.tensionRadius; y: 0 }
                                PathLine { x: 0; y: 0 }
                                PathArc  { x: rootScope.tensionRadius; y: rootScope.tensionRadius
                                           radiusX: rootScope.tensionRadius; radiusY: rootScope.tensionRadius
                                           direction: PathArc.Clockwise }
                            }
                        }
                        Shape {
                            anchors { right: parent.right; top: parent.top }
                            width: rootScope.tensionRadius; height: rootScope.tensionRadius
                            ShapePath {
                                fillColor: Colors.background; strokeWidth: 0
                                startX: rootScope.tensionRadius; startY: 0
                                PathLine { x: 0; y: 0 }
                                PathLine { x: 0; y: rootScope.tensionRadius }
                                PathArc  { x: rootScope.tensionRadius; y: 0
                                           radiusX: rootScope.tensionRadius; radiusY: rootScope.tensionRadius
                                           direction: PathArc.Clockwise }
                            }
                        }
                    }

                    // ── bottom ───────────────────────────────────────────────
                    Item {
                        visible: Config.navbarLocation === "bottom"
                        anchors.fill: parent
                        Shape {
                            anchors { left: parent.left; bottom: parent.bottom }
                            width: rootScope.tensionRadius; height: rootScope.tensionRadius
                            ShapePath {
                                fillColor: Colors.background; strokeWidth: 0
                                startX: 0; startY: rootScope.tensionRadius
                                PathLine { x: rootScope.tensionRadius; y: rootScope.tensionRadius }
                                PathLine { x: rootScope.tensionRadius; y: 0 }
                                PathArc  { x: 0; y: rootScope.tensionRadius
                                           radiusX: rootScope.tensionRadius; radiusY: rootScope.tensionRadius
                                           direction: PathArc.Clockwise }
                            }
                        }
                        Shape {
                            anchors { right: parent.right; bottom: parent.bottom }
                            width: rootScope.tensionRadius; height: rootScope.tensionRadius
                            ShapePath {
                                fillColor: Colors.background; strokeWidth: 0
                                startX: 0; startY: 0
                                PathLine { x: 0; y: rootScope.tensionRadius }
                                PathLine { x: rootScope.tensionRadius; y: rootScope.tensionRadius }
                                PathArc  { x: 0; y: 0
                                           radiusX: rootScope.tensionRadius; radiusY: rootScope.tensionRadius
                                           direction: PathArc.Clockwise }
                            }
                        }
                    }

                    // ── left ─────────────────────────────────────────────────
                    Item {
                        visible: Config.navbarLocation === "left"
                        anchors.fill: parent
                        Shape {
                            anchors { left: parent.left; top: parent.top }
                            width: rootScope.tensionRadius; height: rootScope.tensionRadius
                            ShapePath {
                                fillColor: Colors.background; strokeWidth: 0
                                startX: 0; startY: 0
                                PathLine { x: 0; y: rootScope.tensionRadius }
                                PathLine { x: rootScope.tensionRadius; y: rootScope.tensionRadius }
                                PathArc  { x: 0; y: 0
                                           radiusX: rootScope.tensionRadius; radiusY: rootScope.tensionRadius
                                           direction: PathArc.Clockwise }
                            }
                        }
                        Shape {
                            anchors { left: parent.left; bottom: parent.bottom }
                            width: rootScope.tensionRadius; height: rootScope.tensionRadius
                            ShapePath {
                                fillColor: Colors.background; strokeWidth: 0
                                startX: rootScope.tensionRadius; startY: 0
                                PathLine { x: 0; y: 0 }
                                PathLine { x: 0; y: rootScope.tensionRadius }
                                PathArc  { x: rootScope.tensionRadius; y: 0
                                           radiusX: rootScope.tensionRadius; radiusY: rootScope.tensionRadius
                                           direction: PathArc.Clockwise }
                            }
                        }
                    }

                    // ── right ────────────────────────────────────────────────
                    Item {
                        visible: Config.navbarLocation === "right"
                        anchors.fill: parent
                        Shape {
                            anchors { right: parent.right; top: parent.top }
                            width: rootScope.tensionRadius; height: rootScope.tensionRadius
                            ShapePath {
                                fillColor: Colors.background; strokeWidth: 0
                                startX: 0; startY: rootScope.tensionRadius
                                PathLine { x: rootScope.tensionRadius; y: rootScope.tensionRadius }
                                PathLine { x: rootScope.tensionRadius; y: 0 }
                                PathArc  { x: 0; y: rootScope.tensionRadius
                                           radiusX: rootScope.tensionRadius; radiusY: rootScope.tensionRadius
                                           direction: PathArc.Clockwise }
                            }
                        }
                        Shape {
                            anchors { right: parent.right; bottom: parent.bottom }
                            width: rootScope.tensionRadius; height: rootScope.tensionRadius
                            ShapePath {
                                fillColor: Colors.background; strokeWidth: 0
                                startX: rootScope.tensionRadius; startY: rootScope.tensionRadius
                                PathLine { x: rootScope.tensionRadius; y: 0 }
                                PathLine { x: 0; y: 0 }
                                PathArc  { x: rootScope.tensionRadius; y: rootScope.tensionRadius
                                           radiusX: rootScope.tensionRadius; radiusY: rootScope.tensionRadius
                                           direction: PathArc.Clockwise }
                            }
                        }
                    }
                }
            }
        }
    }
}
