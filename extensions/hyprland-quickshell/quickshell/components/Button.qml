// components/Button.qml
import QtQuick
import qs.globals

Rectangle {
    id: root

    signal buttonClicked()

    property string style:       "circle"
    property string labelText
    property string labelFont
    property real   buttonSize:  28
    property color  buttonColor

    // Size is set entirely by buttonSize — never derived from parent
    width:  style === "circle" ? buttonSize : label.implicitWidth + buttonSize * 0.6
    height: buttonSize
    radius: height / 2
    color:  buttonColor

    Text {
        id: label
        anchors.centerIn: parent
        text:             root.labelText
        font.family:      root.labelFont
        color:            Colors.background
        // Fixed ratio of the button size — not derived from parent.height
        font.pixelSize:   root.buttonSize * 0.6
    }

    MouseArea {
        anchors.fill: parent
        cursorShape:  Qt.PointingHandCursor
        onClicked:    root.buttonClicked()
    }
}
