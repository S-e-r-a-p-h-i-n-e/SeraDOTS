// panels/Dashboard.qml — panel structure only
// Widget components live in engine/DashboardRegistry.qml
// Grid logic lives in engine/DashboardEngine.qml
import QtQuick
import QtQuick.Controls
import Quickshell.Services.Mpris
import qs.components
import qs.engine
import qs.globals
import qs.modules.media
import qs.modules.notifications

Panel {
    id: dashboardPanel

    panelWidth:      Style.panelWidth
    panelHeight:     Style.panelHeight
    animationPreset: "slide"

    property var engine: DashboardEngine {}

    ScrollView {
        id: scroll
        anchors.fill: parent
        clip: true
        ScrollBar.vertical: ScrollBar {
            policy: ScrollBar.AsNeeded
            contentItem: Rectangle { implicitWidth: 4; radius: 2; color: Colors.color7; opacity: 0.4 }
        }
        ScrollBar.horizontal: ScrollBar { policy: ScrollBar.AlwaysOff }
        contentWidth: width

        Column {
            width:      scroll.width
            spacing:    14
            topPadding: 4

            // ── Header ────────────────────────────────────────────────────
            Item {
                width:  parent.width
                height: 44

                Column {
                    anchors.left:           parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2
                    Text {
                        text:           Time.date
                        color:          Colors.foreground
                        font.family:    Style.barFont
                        font.pixelSize: 18
                        font.weight:    Font.ExtraBold
                    }
                }

                Rectangle {
                    anchors.right:          parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    width: 70; height: 28; radius: 14
                    color: engine.editMode ? Colors.color7 : Colors.color0
                    Behavior on color { ColorAnimation { duration: 150 } }
                    Text {
                        anchors.centerIn: parent
                        text:        engine.editMode ? "Done" : "Edit"
                        color:       engine.editMode ? Colors.background : Colors.foreground
                        font.family: Style.barFont; font.pixelSize: 12; font.weight: Font.Bold
                        Behavior on color { ColorAnimation { duration: 150 } }
                    }
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: engine.editMode = !engine.editMode }
                }
            }

            Rectangle { width: parent.width; height: 1; color: Colors.color8; opacity: 0.3 }

            // ── Control center grid ───────────────────────────────────────
            Item {
                width:  parent.width
                height: gridLayout.height + (engine.editMode ? addSheet.height + 10 : 0)
                Behavior on height { NumberAnimation { duration: Animations.normal; easing.type: Animations.easeInOut } }

                Item {
                    id: gridLayout
                    width: parent.width
                    readonly property real cellW: Math.floor((width - (engine.cellGap * 3)) / 4)
                    readonly property real cellH: cellW
                    height: engine.gridHeight
                    onCellWChanged: engine.cellW = cellW

                    Repeater {
                        model: engine.placements

                        delegate: Item {
                            required property var modelData

                            x:      modelData.col  * (gridLayout.cellW + engine.cellGap)
                            y:      modelData.row  * (gridLayout.cellH + engine.cellGap)
                            width:  modelData.cols * gridLayout.cellW + (modelData.cols - 1) * engine.cellGap
                            height: modelData.rows * gridLayout.cellH + (modelData.rows - 1) * engine.cellGap

                            Rectangle {
                                id:            widgetCard
                                anchors.fill:  parent
                                radius:        12
                                color:         Colors.color0
                                clip:          true
                                layer.enabled: true

                                Loader {
                                    anchors.fill:    parent
                                    sourceComponent: ModuleRegistry.resolveWidget(modelData.id)
                                }

                                // Edit mode overlays
                                MouseArea { anchors.fill: parent; enabled: engine.editMode; hoverEnabled: false }
                                Rectangle {
                                    anchors.fill: parent; radius: parent.radius; color: "transparent"
                                    border.width: engine.editMode ? 2 : 0; border.color: Colors.color7
                                    opacity: engine.editMode ? 1 : 0
                                    Behavior on opacity      { NumberAnimation { duration: 150 } }
                                    Behavior on border.width { NumberAnimation { duration: 150 } }
                                }
                                Rectangle {
                                    visible: engine.editMode; opacity: engine.editMode ? 1 : 0
                                    Behavior on opacity { NumberAnimation { duration: 150 } }
                                    anchors.top:     parent.top
                                    anchors.right:   parent.right
                                    anchors.margins: -6
                                    width: 20; height: 20; radius: 10; color: Colors.color1
                                    Text { anchors.centerIn: parent; text: "󰅖"; color: Colors.foreground; font.family: Style.barFont; font.pixelSize: 11 }
                                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: engine.removeWidget(modelData.id) }
                                }
                                Row {
                                    visible: engine.editMode && engine.placements.length > 1
                                    opacity: engine.editMode ? 1 : 0
                                    Behavior on opacity { NumberAnimation { duration: 150 } }
                                    anchors.bottom:              parent.bottom
                                    anchors.horizontalCenter:    parent.horizontalCenter
                                    anchors.bottomMargin:        4
                                    spacing: 4
                                    Rectangle {
                                        visible: modelData.idx > 0
                                        width: 20; height: 20; radius: 10; color: Colors.color8; opacity: 0.7
                                        Text { anchors.centerIn: parent; text: "󰁍"; color: Colors.foreground; font.family: Style.barFont; font.pixelSize: 11 }
                                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: engine.moveWidget(modelData.idx, modelData.idx - 1) }
                                    }
                                    Rectangle {
                                        visible: modelData.idx < engine.activeWidgets.length - 1
                                        width: 20; height: 20; radius: 10; color: Colors.color8; opacity: 0.7
                                        Text { anchors.centerIn: parent; text: "󰁔"; color: Colors.foreground; font.family: Style.barFont; font.pixelSize: 11 }
                                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: engine.moveWidget(modelData.idx, modelData.idx + 1) }
                                    }
                                }
                            }
                        }
                    }
                }

                // Add widget sheet
                Rectangle {
                    id:      addSheet
                    visible: engine.editMode
                    opacity: engine.editMode ? 1 : 0
                    Behavior on opacity { NumberAnimation { duration: 200 } }
                    anchors.top:        gridLayout.bottom
                    anchors.topMargin:  10
                    anchors.left:       parent.left
                    anchors.right:      parent.right
                    height: addGrid.height + 20; radius: 12; color: Colors.color0

                    Column {
                        id: addGrid
                        anchors.left:    parent.left
                        anchors.right:   parent.right
                        anchors.top:     parent.top
                        anchors.margins: 12
                        spacing: 8

                        Text { text: "Add Widget"; color: Colors.color8; font.family: Style.barFont; font.pixelSize: 11; font.weight: Font.ExtraBold; font.letterSpacing: 1.2 }

                        Flow {
                            width: parent.width; spacing: 6
                            Repeater {
                                model: engine.widgetDefs
                                delegate: Rectangle {
                                    required property var modelData
                                    readonly property bool alreadyAdded: engine.activeWidgets.indexOf(modelData.id) !== -1
                                    width: 80; height: 32; radius: 16
                                    color:   alreadyAdded ? Colors.color8 : Colors.color7
                                    opacity: alreadyAdded ? 0.4 : 1.0
                                    Behavior on opacity { NumberAnimation { duration: 150 } }
                                    Behavior on color   { ColorAnimation  { duration: 150 } }
                                    Row {
                                        anchors.centerIn: parent; spacing: 4
                                        Text { text: parent.parent.modelData.icon;  color: alreadyAdded ? Colors.foreground : Colors.background; font.family: Style.barFont; font.pixelSize: 12 }
                                        Text { text: parent.parent.modelData.label; color: alreadyAdded ? Colors.foreground : Colors.background; font.family: Style.barFont; font.pixelSize: 11; font.weight: Font.Bold }
                                    }
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape:  alreadyAdded ? Qt.ArrowCursor : Qt.PointingHandCursor
                                        enabled:      !alreadyAdded
                                        onClicked:    engine.addWidget(modelData.id)
                                    }
                                }
                            }
                        }
                    }
                }
            }

            Rectangle { width: parent.width; height: 1; color: Colors.color8; opacity: 0.3 }

            // ── Media card ────────────────────────────────────────────────
            Rectangle {
                width: parent.width; height: mediaInner.implicitHeight + 24
                radius: 12; color: Colors.color0; visible: Media.hasPlayer

                Column {
                    id: mediaInner
                    anchors.left:    parent.left
                    anchors.right:   parent.right
                    anchors.top:     parent.top
                    anchors.margins: 14
                    spacing: 10

                    Row {
                        width: parent.width; spacing: 12
                        Rectangle {
                            width: 52; height: 52; radius: 8; color: Colors.color8; clip: true
                            Image { anchors.fill: parent; source: Media.artUrl; fillMode: Image.PreserveAspectCrop; smooth: true; visible: Media.artUrl !== "" }
                            Text  { anchors.centerIn: parent; visible: Media.artUrl === ""; text: "󰎆"; color: Colors.color0; font.family: Style.barFont; font.pixelSize: 24 }
                        }
                        Column {
                            width: parent.width - 52 - 12
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2
                            Item {
                                id: titleClip; width: parent.width; height: titleText.implicitHeight; clip: true
                                Text {
                                    id: titleText
                                    text: Media.title; color: Colors.foreground; font.family: Style.barFont; font.pixelSize: 13; font.weight: Font.Bold
                                    onTextChanged:          Qt.callLater(marquee.restart)
                                    onImplicitWidthChanged: Qt.callLater(marquee.restart)
                                }
                                SequentialAnimation {
                                    id: marquee; loops: Animation.Infinite
                                    function restart() {
                                        stop(); titleText.x = 0
                                        if (titleClip.width > 0 && titleText.implicitWidth > titleClip.width) start()
                                    }
                                    PauseAnimation  { duration: 1500 }
                                    NumberAnimation { target: titleText; property: "x"; from: 0; to: -(titleText.implicitWidth + 32); duration: Math.max(1, titleText.implicitWidth * 28); easing.type: Easing.Linear }
                                    PauseAnimation  { duration: 800 }
                                    ScriptAction    { script: titleText.x = titleClip.width }
                                    NumberAnimation { target: titleText; property: "x"; from: titleClip.width; to: 0; duration: Math.max(1, titleClip.width * 28); easing.type: Easing.Linear }
                                }
                                Component.onCompleted: Qt.callLater(marquee.restart)
                            }
                            Text { width: parent.width; text: Media.artist; color: Colors.color7; font.family: Style.barFont; font.pixelSize: 11; elide: Text.ElideRight }
                            Text { width: parent.width; visible: Media.album !== ""; text: Media.album; color: Colors.color8; font.family: Style.barFont; font.pixelSize: 10; elide: Text.ElideRight }
                        }
                    }

                    Column {
                        width: parent.width; spacing: 4
                        Rectangle {
                            id: seekTrack; width: parent.width; height: 4; radius: 2; color: Colors.color8; opacity: 0.4
                            Rectangle { width: Media.length > 0 ? Math.min(1, Media.position / Media.length) * parent.width : 0; height: parent.height; radius: parent.radius; color: Colors.color7 }
                            MouseArea {
                                anchors.fill:    parent
                                anchors.margins: -6
                                cursorShape:     Qt.PointingHandCursor
                                onClicked: (e) => Media.seekTo((e.x / seekTrack.width) * Media.length)
                                onPositionChanged: (e) => {
                                    if (pressed)
                                        Media.seekTo(Math.max(0, Math.min(1, e.x / seekTrack.width)) * Media.length)
                                }
                            }
                        }
                        Item {
                            width: parent.width; height: 12
                            Text {
                                anchors.left:           parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                text: Media.fmt(Media.position); color: Colors.color8; font.family: Style.barFont; font.pixelSize: 10
                            }
                            Text {
                                anchors.right:          parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                text: Media.fmt(Media.length); color: Colors.color8; font.family: Style.barFont; font.pixelSize: 10
                            }
                        }
                    }

                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter; spacing: 8
                        MediaButton { visible: Media.isSpotify; icon: "󰒝"; bgColor: Media.shuffle ? Colors.color7 : Colors.color5; onClicked: Media.toggleShuffle() }
                        MediaButton { icon: "󰒮"; bgColor: Colors.color5; onClicked: Media.prev() }
                        MediaButton { icon: Media.isPlaying ? "󰏤" : "󰐊"; bgColor: Colors.color7; onClicked: Media.toggle() }
                        MediaButton { icon: "󰒭"; bgColor: Colors.color5; onClicked: Media.next() }
                        MediaButton { visible: Media.isSpotify; icon: Media.loopState === MprisLoopState.Track ? "󰑘" : "󰑖"; bgColor: Media.loopState !== MprisLoopState.None ? Colors.color7 : Colors.color5; onClicked: Media.cycleLoop() }
                    }
                }
            }

            Rectangle { width: parent.width; height: 1; color: Colors.color8; opacity: 0.3 }

            // ── Notifications ─────────────────────────────────────────────
            Item {
                width: parent.width; height: 20
                Text {
                    anchors.left:           parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Notifications" + (Notifications.count > 0 ? "  " + Notifications.count : "")
                    color: Colors.foreground; font.family: Style.barFont; font.pixelSize: 13; font.weight: Font.Bold
                }
                Text {
                    visible:                Notifications.count > 0
                    anchors.right:          parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Clear all"; color: Colors.color8; font.family: Style.barFont; font.pixelSize: 11
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: Notifications.dismissAll() }
                }
            }

            Column {
                width: parent.width; spacing: 6
                Repeater {
                    model: Notifications.notifications
                    delegate: Rectangle {
                        id: notifCard
                        required property string app
                        required property string summary
                        required property string body
                        required property string time
                        required property int    index
                        width: parent.width; height: notifContent.implicitHeight + 20; radius: 10; color: Colors.color0

                        Column {
                            id: notifContent
                            anchors.left:           parent.left
                            anchors.right:          dismissBtn.left
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.leftMargin:     12
                            anchors.rightMargin:    8
                            spacing: 3
                            Row {
                                spacing: 6
                                Text { text: notifCard.app;  color: Colors.color7; font.family: Style.barFont; font.pixelSize: 10; font.weight: Font.Bold }
                                Text { text: notifCard.time; color: Colors.color8; font.family: Style.barFont; font.pixelSize: 10; opacity: 0.6 }
                            }
                            Text { width: notifContent.width; visible: text !== ""; text: notifCard.summary; color: Colors.foreground; font.family: Style.barFont; font.pixelSize: 12; font.weight: Font.Bold; elide: Text.ElideRight }
                            Text { width: notifContent.width; visible: text !== ""; text: notifCard.body; color: Colors.color8; font.family: Style.barFont; font.pixelSize: 11; wrapMode: Text.WordWrap; maximumLineCount: 2; elide: Text.ElideRight }
                        }
                        Text {
                            id:                     dismissBtn
                            anchors.right:          parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.rightMargin:    12
                            text: "󰅖"; color: Colors.color8; font.family: Style.barFont; font.pixelSize: 14
                            MouseArea { anchors.fill: parent; anchors.margins: -6; cursorShape: Qt.PointingHandCursor; onClicked: Notifications.dismissAt(notifCard.index) }
                        }
                    }
                }
                Text {
                    visible:                  Notifications.count === 0
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "No notifications"; color: Colors.color8; font.family: Style.barFont; font.pixelSize: 12; opacity: 0.5
                }
            }

            Item { width: 1; height: 4 }
        }
    }

    // MediaButton stays here — it's media card specific, not a widget
    component MediaButton: Rectangle {
        property string icon:    ""
        property color  bgColor: Colors.color0
        signal clicked()
        width: 36; height: 36; radius: 18; color: bgColor
        Text { anchors.centerIn: parent; text: parent.icon; color: Colors.background; font.family: Style.barFont; font.pixelSize: 16 }
        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: parent.clicked() }
    }
}
