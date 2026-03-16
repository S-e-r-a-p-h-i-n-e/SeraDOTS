// modules/clock/ClockView.qml
import QtQuick
import qs.globals
import qs.modules.clock

Item {
    id: root
    property bool isHorizontal: Config.isHorizontal
    property real barThickness: Style.moduleSize
    property var  barScreen:    null

    readonly property string timeHour: Clock.time.split(":")[0] ?? ""
    readonly property string timeMin:  Clock.time.split(":")[1] ?? ""

    implicitWidth:  isHorizontal ? hPill.implicitWidth : barThickness
    implicitHeight: isHorizontal ? barThickness        : vPill.height

    // ── Horizontal ────────────────────────────────────────────────────────
    Rectangle {
        id: hPill
        visible:          root.isHorizontal
        anchors.centerIn: parent
        implicitWidth:    timeText.implicitWidth + root.barThickness * 0.6
        height:           root.barThickness
        radius:           height / 2
        color:            Colors.color0

        Text {
            id: timeText
            anchors.centerIn: parent
            text:           Clock.time
            font.family:    Style.barFont
            font.pixelSize: root.barThickness * 0.48
            font.weight:    Font.Bold
            color:          Colors.foreground
        }
    }

    // ── Vertical ──────────────────────────────────────────────────────────
    Rectangle {
        id: vPill
        visible:          !root.isHorizontal
        anchors.centerIn: parent
        width:   root.barThickness
        height:  vInner.implicitHeight + root.barThickness * 0.6
        radius:  root.barThickness / 2
        color:   Colors.color0

        Column {
            id: vInner
            anchors.centerIn: parent
            spacing: 0

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text:           root.timeHour
                font.family:    Style.barFont
                font.pixelSize: root.barThickness * 0.48
                font.weight:    Font.Bold
                color:          Colors.foreground
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text:           root.timeMin
                font.family:    Style.barFont
                font.pixelSize: root.barThickness * 0.48
                font.weight:    Font.Bold
                color:          Colors.foreground
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape:  Qt.PointingHandCursor
        onClicked:    EventBus.togglePanel("dashboard", root.barScreen)
    }
}
