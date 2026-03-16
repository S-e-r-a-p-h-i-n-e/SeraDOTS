// modules/cava/CavaView.qml
import QtQuick
import qs.globals

Item {
    id: root
    property bool   isHorizontal: true
    property real   barThickness: 28
    property bool   inPill:       false
    property string barFont:      "JetBrainsMono Nerd Font"

    // Cava only makes sense horizontally — hides in vertical layouts
    visible:        Cava.present && root.isHorizontal
    implicitWidth:  visible ? label.implicitWidth + 20 : 0
    implicitHeight: visible ? barThickness             : 0

    Text {
        id: label
        anchors.centerIn: parent
        text:           Cava.bars
        color:          Colors.color6
        font.family:    root.barFont
        font.pixelSize: root.barThickness * 0.55
    }
}
