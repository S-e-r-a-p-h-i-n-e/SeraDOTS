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
        model: Config.loaded ? Quickshell.screens : [] // FIXED: Changed null to [] to prevent Variant warnings

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
                onClicked:    EventBus.togglePanel(rootScope.panelId, null) // FIXED: Added null to satisfy arguments
                hoverEnabled: false
                enabled: !animator.isAnimating
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

            // NEW: Global panel shortcut for the Escape key
            Shortcut {
                sequence: "Escape"
                onActivated: {
                    if (rootScope.showPanel && !animator.isAnimating) {
                        EventBus.togglePanel(rootScope.panelId, null)
                    }
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

            // Sized exactly to the panel — no excess surface for blur to spill onto.
            implicitWidth:  rootScope.isHorizontal
                ? rootScope.panelWidth + (rootScope.tensionRadius * 2)
                : rootScope.panelWidth
            implicitHeight: !rootScope.isHorizontal
                ? rootScope.panelHeight + (rootScope.tensionRadius * 2)
                : rootScope.panelHeight

            // ── AnimatedElement ───────────────────────────────────────────
            AnimatedElement {
                id: animator
                anchors.fill: parent
                show:   rootScope.showPanel && isTargetScreen
                preset: rootScope.animationPreset
                edge:   rootScope.barEdge

                // ── Panel background ──────────────────────────────────────
                Rectangle {
                    id: bg
                    
                    // FIX: Hardcode the width/height to the panel dimensions
                    // so it doesn't expand into the fillet zones!
                    width:  rootScope.panelWidth
                    height: rootScope.panelHeight
                    
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
                        // Center it horizontally or vertically depending on orientation
                        horizontalCenter: rootScope.isHorizontal  ? parent.horizontalCenter : undefined
                        verticalCenter:   !rootScope.isHorizontal ? parent.verticalCenter   : undefined

                        // Anchor the flat edge to the bar
                        top:    Config.navbarLocation === "top"    ? parent.top    : undefined
                        bottom: Config.navbarLocation === "bottom" ? parent.bottom : undefined
                        left:   Config.navbarLocation === "left"   ? parent.left   : undefined
                        right:  Config.navbarLocation === "right"  ? parent.right  : undefined

                        // Square off the connecting edge
                        topMargin:    (!Config.transparentNavbar && Config.navbarLocation === "top")    ? -radius : 0
                        bottomMargin: (!Config.transparentNavbar && Config.navbarLocation === "bottom") ? -radius : 0
                        leftMargin:   (!Config.transparentNavbar && Config.navbarLocation === "left")   ? -radius : 0
                        rightMargin:  (!Config.transparentNavbar && Config.navbarLocation === "right")  ? -radius : 0
                    }
                }

                // ── Panel content ─────────────────────────────────────────
                Item {
                    anchors.fill:    bg // Anchor to the restricted bg, not the parent!
                    anchors.margins: Style.panelPadding
                    clip: true

                    Loader {
                        anchors.fill:    parent
                        sourceComponent: rootScope.panelContent
                    }

                    // Block all mouse input while the panel is animating in or out
                    MouseArea {
                        anchors.fill: parent
                        enabled:      animator.isAnimating
                        hoverEnabled: false
                    }
                }

                // ── Tension fillets ───────────────────────────────────────
                Item {
                    anchors.fill: parent
                    
                    // Only show fillets if it's sliding and NOT transparent
                    visible: rootScope.animationPreset === "slide" && !Config.transparentNavbar
                    
                    // ── top (Horizontal) ──────────────────────────────────
                    Item {
                        visible: Config.navbarLocation === "top"
                        anchors.fill: parent
                        
                        // Left Fillet (╮)
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
                        // Right Fillet (╭)
                        Shape {
                            anchors { right: parent.right; top: parent.top }
                            width: rootScope.tensionRadius; height: rootScope.tensionRadius
                            ShapePath {
                                fillColor: Colors.background; strokeWidth: 0
                                startX: 0; startY: rootScope.tensionRadius
                                PathLine { x: 0; y: 0 }
                                PathLine { x: rootScope.tensionRadius; y: 0 }
                                PathArc  { x: 0; y: rootScope.tensionRadius
                                           radiusX: rootScope.tensionRadius; radiusY: rootScope.tensionRadius
                                           direction: PathArc.Counterclockwise }
                            }
                        }
                    }

                    // ── bottom (Horizontal) ───────────────────────────────
                    Item {
                        visible: Config.navbarLocation === "bottom"
                        anchors.fill: parent
                        Shape {
                            anchors { left: parent.left; bottom: parent.bottom }
                            width: rootScope.tensionRadius; height: rootScope.tensionRadius
                            ShapePath {
                                fillColor: Colors.background; strokeWidth: 0
                                startX: rootScope.tensionRadius; startY: 0
                                PathLine { x: rootScope.tensionRadius; y: rootScope.tensionRadius }
                                PathLine { x: 0; y: rootScope.tensionRadius }
                                PathArc  { x: rootScope.tensionRadius; y: 0
                                           radiusX: rootScope.tensionRadius; radiusY: rootScope.tensionRadius
                                           direction: PathArc.Counterclockwise } 
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

                    // ── left (Vertical) ───────────────────────────────────
                    Item {
                        visible: Config.navbarLocation === "left"
                        anchors.fill: parent
                        Shape {
                            anchors { left: parent.left; top: parent.top }
                            width: rootScope.tensionRadius; height: rootScope.tensionRadius
                            ShapePath {
                                fillColor: Colors.background; strokeWidth: 0
                                startX: rootScope.tensionRadius; startY: rootScope.tensionRadius
                                PathLine { x: 0; y: rootScope.tensionRadius }
                                PathLine { x: 0; y: 0 }
                                PathArc  { x: rootScope.tensionRadius; y: rootScope.tensionRadius
                                           radiusX: rootScope.tensionRadius; radiusY: rootScope.tensionRadius
                                           direction: PathArc.Counterclockwise } 
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

                    // ── right (Vertical) ──────────────────────────────────
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
                                startX: 0; startY: 0
                                PathLine { x: rootScope.tensionRadius; y: 0 }
                                PathLine { x: rootScope.tensionRadius; y: rootScope.tensionRadius }
                                PathArc  { x: 0; y: 0
                                           radiusX: rootScope.tensionRadius; radiusY: rootScope.tensionRadius
                                           direction: PathArc.Counterclockwise } 
                            }
                        }
                    }
                }
            }
        }
    }
}