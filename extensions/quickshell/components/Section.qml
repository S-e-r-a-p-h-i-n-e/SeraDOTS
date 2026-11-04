// components/Section.qml
import QtQuick
import qs.globals

Item {
    id: sectionRoot
    property string label: "Section"

    property int topSpacing:    16
    property int bottomSpacing: 16

    width: parent.width
    height: sectionText.implicitHeight + topSpacing + bottomSpacing

    Text {
        id: sectionText

        anchors.top:        parent.top
        anchors.topMargin:  sectionRoot.topSpacing

        // ── CHANGE: Anchor to the center instead of the left ─────────────
        anchors.horizontalCenter: parent.horizontalCenter

        text:               sectionRoot.label.toUpperCase()
        color:              Colors.foreground
        font.family:        Style.barFont
        font.pixelSize:     10
        font.weight:        Font.ExtraBold
        font.letterSpacing: 1.5
    }

    Rectangle {
        anchors.bottom:      parent.bottom
        anchors.left:        parent.left
        anchors.right:       parent.right
        height:              1
        color:               Colors.color8
        opacity:             0.5
    }
}
