// components/ScreenBorder.qml
// qmllint disable
import Quickshell
import QtQuick
import QtQuick.Shapes
import qs.globals

Scope {
    id: border

    property bool   enabled:      true
    property string location
    property real   borderWidth
    property real   cornerRadius
    property color  borderColor

    // Fade the border color alpha so edges and corners animate in/out
    // smoothly rather than snapping when enableBorders is toggled.
    // animatedAlpha is tracked separately so PanelWindows can be hidden
    // once the fade completes — keeping them visible: true while transparent
    // would leave invisible windows consuming compositor exclusion zones.
    property real animatedAlpha: border.enabled ? 1.0 : 0.0
    Behavior on animatedAlpha { NumberAnimation { duration: Animations.normal; easing.type: Animations.easeInOut } }

    // borderWidth animates to 0 when disabled, but cornerRadius always stays
    // active so the screen corners are always rounded regardless of border state.
    property real animatedBorderWidth:  border.enabled ? border.borderWidth : 0
    property real animatedCornerRadius: border.cornerRadius
    Behavior on animatedBorderWidth  { NumberAnimation { duration: Animations.normal; easing.type: Animations.easeInOut } }
    Behavior on animatedCornerRadius { NumberAnimation { duration: Animations.normal; easing.type: Animations.easeInOut } }

    readonly property color animatedColor: Qt.rgba(
        borderColor.r,
        borderColor.g,
        borderColor.b,
        animatedAlpha
    )

    // Corners always stay fully opaque — they persist even when borders are
    // disabled to keep the screen corners rounded at all times.
    // Exception: transparent mode hides them since there's no solid bar to blend into.
    property real animatedCornerAlpha: Config.transparentNavbar ? 0.0 : 1.0
    Behavior on animatedCornerAlpha { NumberAnimation { duration: Animations.normal; easing.type: Animations.easeInOut } }

    readonly property color animatedCornerColor: Qt.rgba(
        borderColor.r,
        borderColor.g,
        borderColor.b,
        animatedCornerAlpha
    )

    Variants {
        model: Quickshell.screens

        Scope {
            required property var modelData
            property var currentScreen: modelData

            // ── straight edges ────────────────────────────────────────────
            PanelWindow {
                screen:         currentScreen
                anchors { top: true; left: true; right: true }
                implicitHeight: border.animatedBorderWidth
                color:          border.animatedColor
                visible: border.animatedAlpha > 0 && border.animatedBorderWidth > 0 && border.location !== "top"
            }
            PanelWindow {
                screen:        currentScreen
                anchors { top: true; left: true; bottom: true }
                implicitWidth: border.animatedBorderWidth
                color:         border.animatedColor
                visible:       border.animatedAlpha > 0 && border.animatedBorderWidth > 0 && border.location !== "left"
            }
            PanelWindow {
                screen:         currentScreen
                anchors { bottom: true; left: true; right: true }
                implicitHeight: border.animatedBorderWidth
                color:          border.animatedColor
                visible:        border.animatedAlpha > 0 && border.animatedBorderWidth > 0 && border.location !== "bottom"
            }
            PanelWindow {
                screen:        currentScreen
                anchors { top: true; right: true; bottom: true }
                implicitWidth: border.animatedBorderWidth
                color:         border.animatedColor
                visible:       border.animatedAlpha > 0 && border.animatedBorderWidth > 0 && border.location !== "right"
            }

            // ── corners ───────────────────────────────────────────────────
            PanelWindow {
                screen: currentScreen
                anchors { top: true; left: true }
                implicitHeight: border.animatedCornerRadius
                implicitWidth:  border.animatedCornerRadius
                color:   "transparent"
                visible: border.animatedCornerRadius > 0 && !Config.transparentNavbar
                Shape {
                    width: border.animatedCornerRadius; height: border.animatedCornerRadius
                    preferredRendererType: Shape.CurveRenderer
                    ShapePath {
                        strokeWidth: 0; fillColor: border.animatedCornerColor
                        startX: 0; startY: border.animatedCornerRadius
                        PathArc  { x: border.animatedCornerRadius; y: 0; radiusX: border.animatedCornerRadius; radiusY: border.animatedCornerRadius; direction: PathArc.Clockwise }
                        PathLine { x: 0; y: 0 }
                        PathLine { x: 0; y: border.animatedCornerRadius }
                    }
                }
            }
            PanelWindow {
                screen: currentScreen
                anchors { top: true; right: true }
                implicitHeight: border.animatedCornerRadius
                implicitWidth:  border.animatedCornerRadius
                color:   "transparent"
                visible: border.animatedCornerRadius > 0 && !Config.transparentNavbar
                Shape {
                    width: border.animatedCornerRadius; height: border.animatedCornerRadius
                    preferredRendererType: Shape.CurveRenderer
                    ShapePath {
                        strokeWidth: 0; fillColor: border.animatedCornerColor
                        startX: 0; startY: 0
                        PathArc  { x: border.animatedCornerRadius; y: border.animatedCornerRadius; radiusX: border.animatedCornerRadius; radiusY: border.animatedCornerRadius; direction: PathArc.Clockwise }
                        PathLine { x: border.animatedCornerRadius; y: 0 }
                        PathLine { x: 0; y: 0 }
                    }
                }
            }
            PanelWindow {
                screen: currentScreen
                anchors { bottom: true; left: true }
                implicitHeight: border.animatedCornerRadius
                implicitWidth:  border.animatedCornerRadius
                color:   "transparent"
                visible: border.animatedCornerRadius > 0 && !Config.transparentNavbar
                Shape {
                    width: border.animatedCornerRadius; height: border.animatedCornerRadius
                    preferredRendererType: Shape.CurveRenderer
                    ShapePath {
                        strokeWidth: 0; fillColor: border.animatedCornerColor
                        startX: border.animatedCornerRadius; startY: border.animatedCornerRadius
                        PathArc  { x: 0; y: 0; radiusX: border.animatedCornerRadius; radiusY: border.animatedCornerRadius; direction: PathArc.Clockwise }
                        PathLine { x: 0; y: border.animatedCornerRadius }
                        PathLine { x: border.animatedCornerRadius; y: border.animatedCornerRadius }
                    }
                }
            }
            PanelWindow {
                screen: currentScreen
                anchors { bottom: true; right: true }
                implicitHeight: border.animatedCornerRadius
                implicitWidth:  border.animatedCornerRadius
                color:   "transparent"
                visible: border.animatedCornerRadius > 0 && !Config.transparentNavbar
                Shape {
                    width: border.animatedCornerRadius; height: border.animatedCornerRadius
                    preferredRendererType: Shape.CurveRenderer
                    ShapePath {
                        strokeWidth: 0; fillColor: border.animatedCornerColor
                        startX: 0; startY: border.animatedCornerRadius
                        PathLine { x: border.animatedCornerRadius; y: border.animatedCornerRadius }
                        PathLine { x: border.animatedCornerRadius; y: 0 }
                        PathArc  { x: 0; y: border.animatedCornerRadius; radiusX: border.animatedCornerRadius; radiusY: border.animatedCornerRadius; direction: PathArc.Clockwise }
                    }
                }
            }
        }
    }
}
