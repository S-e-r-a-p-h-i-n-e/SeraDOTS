// modules/media/MediaView.qml
import QtQuick
import qs.globals

Item {
    id: root
    property bool isHorizontal: Config.isHorizontal
    property real barThickness: Style.moduleSize

    visible:        Media.hasPlayer
    implicitWidth:  visible ? (isHorizontal ? row.implicitWidth : barThickness) : 0
    implicitHeight: visible ? (isHorizontal ? barThickness      : col.implicitHeight) : 0

    // Shared button delegate — prev/play/next are all the same shape
    component MediaButton: Rectangle {
        property string icon
        property color  bgColor: Colors.color0
        signal clicked()

        width:  root.barThickness
        height: root.barThickness
        radius: height / 2
        color:  bgColor

        Text {
            anchors.centerIn: parent
            text:           parent.icon
            font.family:    Style.barFont
            font.pixelSize: root.barThickness * 0.6
            color:          Colors.background
        }
        MouseArea {
            anchors.fill: parent
            cursorShape:  Qt.PointingHandCursor
            onClicked:    parent.clicked()
        }
    }

    // ── Horizontal ────────────────────────────────────────────────────────
    Row {
        id: row
        visible:          root.isHorizontal
        anchors.centerIn: parent
        spacing: 4

        MediaButton { icon: "󰒮"; bgColor: Colors.color5; onClicked: Media.prev() }
        MediaButton { icon: Media.isPlaying ? "󰏤" : "󰐊"; bgColor: Colors.color7; onClicked: Media.toggle() }
        MediaButton { icon: "󰒭"; bgColor: Colors.color5; onClicked: Media.next() }

        // Title pill — only shown when there's a title
        Rectangle {
            visible:       Media.title !== ""
            height:        root.barThickness
            implicitWidth: titleText.implicitWidth + root.barThickness * 0.6
            radius:        height / 2
            color:         Colors.color0

            Text {
                id: titleText
                anchors.centerIn: parent
                text:           Media.title
                font.family:    Style.barFont
                font.pixelSize: root.barThickness * 0.48
                font.weight:    Font.Bold
                color:          Colors.foreground
            }
        }
    }

    // ── Vertical ──────────────────────────────────────────────────────────
    Column {
        id: col
        visible:          !root.isHorizontal
        anchors.centerIn: parent
        spacing: 4

        MediaButton { anchors.horizontalCenter: parent.horizontalCenter; icon: "󰒮"; bgColor: Colors.color5; onClicked: Media.prev() }
        MediaButton { anchors.horizontalCenter: parent.horizontalCenter; icon: Media.isPlaying ? "󰏤" : "󰐊"; bgColor: Colors.color7; onClicked: Media.toggle() }
        MediaButton { anchors.horizontalCenter: parent.horizontalCenter; icon: "󰒭"; bgColor: Colors.color5; onClicked: Media.next() }
    }
}
