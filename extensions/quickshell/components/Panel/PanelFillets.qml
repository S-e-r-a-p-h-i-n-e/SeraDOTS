// components/Panel/PanelFillets.qml
import QtQuick
import QtQuick.Shapes
import qs.globals

Item {
    id: filletsRoot // <-- Explicit lookup target for ShapePath

    anchors.fill: parent

    required property real   tensionRadius
    required property string navbarLocation
    required property color  fillColor
    required property string animationPreset

    visible: animationPreset === "slide" && !Config.transparentNavbar

    // ── Top (horizontal bar) ───────────────────────────────────────────────
    Item {
        visible: navbarLocation === "top"
        anchors.fill: parent

        Shape {
            anchors { left: parent.left; top: parent.top }
            width: tensionRadius; height: tensionRadius
            ShapePath {
                fillColor: filletsRoot.fillColor // <-- Targeted explicitly
                strokeWidth: 0
                startX: tensionRadius; startY: tensionRadius
                PathLine { x: tensionRadius; y: 0 }
                PathLine { x: 0; y: 0 }
                PathArc  { x: tensionRadius; y: tensionRadius
                           radiusX: tensionRadius; radiusY: tensionRadius
                           direction: PathArc.Clockwise }
            }
        }
        Shape {
            anchors { right: parent.right; top: parent.top }
            width: tensionRadius; height: tensionRadius
            ShapePath {
                fillColor: filletsRoot.fillColor
                strokeWidth: 0
                startX: 0; startY: tensionRadius
                PathLine { x: 0; y: 0 }
                PathLine { x: tensionRadius; y: 0 }
                PathArc  { x: 0; y: tensionRadius
                           radiusX: tensionRadius; radiusY: tensionRadius
                           direction: PathArc.Counterclockwise }
            }
        }
    }

    // ── Bottom (horizontal bar) ────────────────────────────────────────────
    Item {
        visible: navbarLocation === "bottom"
        anchors.fill: parent

        Shape {
            anchors { left: parent.left; bottom: parent.bottom }
            width: tensionRadius; height: tensionRadius
            ShapePath {
                fillColor: filletsRoot.fillColor
                strokeWidth: 0
                startX: tensionRadius; startY: 0
                PathLine { x: tensionRadius; y: tensionRadius }
                PathLine { x: 0; y: tensionRadius }
                PathArc  { x: tensionRadius; y: 0
                           radiusX: tensionRadius; radiusY: tensionRadius
                           direction: PathArc.Counterclockwise }
            }
        }
        Shape {
            anchors { right: parent.right; bottom: parent.bottom }
            width: tensionRadius; height: tensionRadius
            ShapePath {
                fillColor: filletsRoot.fillColor
                strokeWidth: 0
                startX: 0; startY: 0
                PathLine { x: 0; y: tensionRadius }
                PathLine { x: tensionRadius; y: tensionRadius }
                PathArc  { x: 0; y: 0
                           radiusX: tensionRadius; radiusY: tensionRadius
                           direction: PathArc.Clockwise }
            }
        }
    }

    // ── Left (vertical bar) ────────────────────────────────────────────────
    Item {
        visible: navbarLocation === "left"
        anchors.fill: parent

        Shape {
            anchors { left: parent.left; top: parent.top }
            width: tensionRadius; height: tensionRadius
            ShapePath {
                fillColor: filletsRoot.fillColor
                strokeWidth: 0
                startX: tensionRadius; startY: tensionRadius
                PathLine { x: 0; y: tensionRadius }
                PathLine { x: 0; y: 0 }
                PathArc  { x: tensionRadius; y: tensionRadius
                           radiusX: tensionRadius; radiusY: tensionRadius
                           direction: PathArc.Counterclockwise }
            }
        }
        Shape {
            anchors { left: parent.left; bottom: parent.bottom }
            width: tensionRadius; height: tensionRadius
            ShapePath {
                fillColor: filletsRoot.fillColor
                strokeWidth: 0
                startX: tensionRadius; startY: 0
                PathLine { x: 0; y: 0 }
                PathLine { x: 0; y: tensionRadius }
                PathArc  { x: tensionRadius; y: 0
                           radiusX: tensionRadius; radiusY: tensionRadius
                           direction: PathArc.Clockwise }
            }
        }
    }

    // ── Right (vertical bar) ───────────────────────────────────────────────
    Item {
        visible: navbarLocation === "right"
        anchors.fill: parent

        Shape {
            anchors { right: parent.right; top: parent.top }
            width: tensionRadius; height: tensionRadius
            ShapePath {
                fillColor: filletsRoot.fillColor
                strokeWidth: 0
                startX: 0; startY: tensionRadius
                PathLine { x: tensionRadius; y: tensionRadius }
                PathLine { x: tensionRadius; y: 0 }
                PathArc  { x: 0; y: tensionRadius
                           radiusX: tensionRadius; radiusY: tensionRadius
                           direction: PathArc.Clockwise }
            }
        }
        Shape {
            anchors { right: parent.right; bottom: parent.bottom }
            width: tensionRadius; height: tensionRadius
            ShapePath {
                fillColor: filletsRoot.fillColor
                strokeWidth: 0
                startX: 0; startY: 0
                PathLine { x: tensionRadius; y: 0 }
                PathLine { x: tensionRadius; y: tensionRadius }
                PathArc  { x: 0; y: 0
                           radiusX: tensionRadius; radiusY: tensionRadius
                           direction: PathArc.Counterclockwise }
            }
        }
    }
}
