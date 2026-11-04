// components/Panel/PanelBackground.qml
import QtQuick
import qs.globals

Item {
    id: root

    required property real     panelWidth
    required property real     panelHeight
    required property real     panelRadius
    required property real     tensionRadius
    required property string   navbarLocation
    required property bool     isHorizontal
    required property string   animationPreset
    required property bool     isAnimating
    required property Component panelContent

    // ── Background rectangle ───────────────────────────────────────────────
    Rectangle {
        id: bg

        width:  root.panelWidth
        height: root.panelHeight

        color:  Config.transparentNavbar
                ? Qt.rgba(Colors.background.r, Colors.background.g, Colors.background.b, 0.01)
                : Colors.background
        radius:  root.panelRadius
        border.width: Config.transparentNavbar ? 1 : 0
        border.color: Config.transparentNavbar ? Qt.rgba(1, 1, 1, 0.15) : "transparent"

        Behavior on color        { ColorAnimation  { duration: Animations.normal; easing.type: Animations.easeInOut } }
        Behavior on border.color { ColorAnimation  { duration: Animations.normal; easing.type: Animations.easeInOut } }
        Behavior on border.width { NumberAnimation { duration: Animations.normal; easing.type: Animations.easeInOut } }

        anchors {
            horizontalCenter: root.isHorizontal  ? parent.horizontalCenter : undefined
            verticalCenter:   !root.isHorizontal ? parent.verticalCenter   : undefined

            top:    root.navbarLocation === "top"    ? parent.top    : undefined
            bottom: root.navbarLocation === "bottom" ? parent.bottom : undefined
            left:   root.navbarLocation === "left"   ? parent.left   : undefined
            right:  root.navbarLocation === "right"  ? parent.right  : undefined

            topMargin:    (!Config.transparentNavbar && root.navbarLocation === "top")    ? -radius : 0
            bottomMargin: (!Config.transparentNavbar && root.navbarLocation === "bottom") ? -radius : 0
            leftMargin:   (!Config.transparentNavbar && root.navbarLocation === "left")   ? -radius : 0
            rightMargin:  (!Config.transparentNavbar && root.navbarLocation === "right")  ? -radius : 0
        }
    }

    // ── Content area ───────────────────────────────────────────────────────
    Item {
        anchors.fill:    bg
        anchors.margins: Style.panelPadding
        clip: true

        Loader {
            anchors.fill:    parent
            sourceComponent: root.panelContent
        }

        MouseArea {
            anchors.fill: parent
            enabled:      root.isAnimating
            hoverEnabled: false
        }
    }

    // ── Tension fillets ────────────────────────────────────────────────────
    PanelFillets {
        anchors.fill:    parent // <-- Crucial: matching the monolith's layout area
        tensionRadius:   root.tensionRadius
        navbarLocation:  root.navbarLocation
        fillColor:       bg.color // <-- Passes the reactive color including transparency shifts
        animationPreset: root.animationPreset
    }
}
