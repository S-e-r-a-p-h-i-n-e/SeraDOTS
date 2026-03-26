// modules/workspaces/WorkspacesView.qml — FRONTEND ONLY
import QtQuick
import qs.globals
import qs.modules.workspaces

Item {
    id: root

    property bool isHorizontal: Config.isHorizontal
    property real barThickness: Style.moduleSize
    property bool inPill:       false

    readonly property real dotSize:      barThickness
    readonly property real iconSize:     dotSize * 0.75
    readonly property real wsSpacing:    Style.slotSpacing + 7   // gap between workspaces
    readonly property real listSpacing:  6                        // gap between app dots
    readonly property int  maxIcons:     5
    readonly property real maxListSize:  (dotSize + listSpacing) * maxIcons - listSpacing

    implicitWidth:  isHorizontal ? (container.implicitWidth  + dotSize * 0.6) : barThickness
    implicitHeight: isHorizontal ? barThickness                                : (container.implicitHeight + dotSize * 0.6)

    Grid {
        id: container
        anchors.centerIn: parent
        columns: root.isHorizontal ? 0 : 1
        rows:    root.isHorizontal ? 1 : 0
        spacing: root.wsSpacing

        Repeater {
            id: workspaceRepeater
            model: Workspaces.workspaces

            delegate: Item {
                id: wsDelegate
                required property var modelData
                required property int index

                readonly property real naturalListSize: appList.count > 0
                    ? appList.count * (root.dotSize + root.listSpacing) - root.listSpacing
                    : root.dotSize
                readonly property real clampedListSize: Math.min(naturalListSize, root.maxListSize)
                readonly property bool hasOverflow: appList.count > root.maxIcons

                implicitWidth:  root.isHorizontal
                    ? (emptyDot.visible ? root.dotSize : clampedListSize)
                    : root.dotSize
                implicitHeight: root.isHorizontal
                    ? root.dotSize
                    : (emptyDot.visible ? root.dotSize : clampedListSize)

                // Empty workspace dot
                Rectangle {
                    id: emptyDot
                    visible: appList.count === 0
                    anchors.centerIn: parent
                    height: root.dotSize
                    width:  height
                    radius: height / 2
                    color:  emptyWsArea.containsMouse
                        ? Colors.foreground
                        : (wsDelegate.modelData.focused ? Colors.color3 : Colors.color7)
                    Behavior on color { ColorAnimation { duration: 150 } }

                    Text {
                        anchors.centerIn: parent
                        text:           wsDelegate.modelData.focused ? "󰣇" : wsDelegate.modelData.name
                        color:          emptyWsArea.containsMouse
                            ? Colors.background
                            : (wsDelegate.modelData.focused ? Colors.background : Colors.foreground)
                        Behavior on color { ColorAnimation { duration: 150 } }
                        font.family:    Style.barFont
                        font.pixelSize: root.iconSize
                        font.weight:    Font.ExtraBold
                    }

                    MouseArea {
                        id: emptyWsArea
                        anchors.fill: parent
                        cursorShape:  Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked:    Workspaces.activate(wsDelegate.modelData)
                    }
                }

                // Scrollable app dot list
                ListView {
                    id: appList
                    visible: count > 0
                    anchors.centerIn: parent

                    width:  root.isHorizontal ? wsDelegate.clampedListSize : root.barThickness
                    height: root.isHorizontal ? root.barThickness          : wsDelegate.clampedListSize

                    orientation:    root.isHorizontal ? ListView.Horizontal : ListView.Vertical
                    spacing:        root.listSpacing
                    clip:           true
                    interactive:    false
                    boundsBehavior: Flickable.StopAtBounds
                    model:          wsDelegate.modelData.toplevels

                    property real scrollTarget: 0

                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.NoButton
                        onWheel: (event) => {
                            let step = root.dotSize + root.listSpacing
                            let maxScroll = Math.max(0,
                                appList.count * step - root.listSpacing - (root.isHorizontal ? appList.width : appList.height))
                            let delta = event.angleDelta.y !== 0 ? event.angleDelta.y : event.angleDelta.x
                            appList.scrollTarget = Math.max(0, Math.min(maxScroll,
                                appList.scrollTarget + (delta > 0 ? -step : step)))
                            scrollAnim.restart()
                        }
                    }

                    SmoothedAnimation {
                        id: scrollAnim
                        target:   appList
                        property: root.isHorizontal ? "contentX" : "contentY"
                        to:       appList.scrollTarget
                        velocity: 400
                    }

                    delegate: Rectangle {
                        id: appDot
                        required property var modelData
                        required property int index

                        readonly property bool isFocused: modelData.activated && wsDelegate.modelData.focused

                        width:  root.isHorizontal ? root.dotSize     : root.barThickness
                        height: root.isHorizontal ? root.barThickness : root.dotSize
                        color:  "transparent"

                        Rectangle {
                            anchors.centerIn: parent
                            height: root.dotSize
                            width:  height
                            radius: height / 2
                            color:  appArea.containsMouse
                                ? Colors.foreground
                                : (appDot.isFocused ? Colors.color3 : Colors.color7)
                            Behavior on color { ColorAnimation { duration: 150 } }

                            Text {
                                anchors.centerIn: parent
                                text:           Workspaces.iconFor(appDot.modelData)
                                color:          appArea.containsMouse
                                    ? Colors.background
                                    : (appDot.isFocused ? Colors.color7 : Colors.color3)
                                Behavior on color { ColorAnimation { duration: 150 } }
                                font.family:    Style.barFont
                                font.pixelSize: root.iconSize
                                font.weight:    Font.Bold
                            }

                            // Small pin indicator at the bottom for pinned apps
                            Rectangle {
                                visible: Workspaces.isPinned(appDot.modelData)
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.bottom: parent.bottom
                                anchors.bottomMargin: 2
                                width:  4
                                height: 4
                                radius: 2
                                color:  appDot.isFocused ? Colors.color7 : Colors.color0
                            }
                        }

                        MouseArea {
                            id: appArea
                            anchors.fill: parent
                            cursorShape:  Qt.PointingHandCursor
                            hoverEnabled: true
                            acceptedButtons: Qt.LeftButton | Qt.RightButton
                            onClicked: (event) => {
                                if (event.button === Qt.RightButton) {
                                    Workspaces.togglePin(appDot.modelData)
                                } else {
                                    Workspaces.focusWindow(appDot.modelData.address)
                                }
                            }
                        }
                    }
                }

                // Separator between workspaces
                Rectangle {
                    visible: wsDelegate.index < (workspaceRepeater.count - 1)
                    width:   root.isHorizontal ? 2                        : root.dotSize * 0.5
                    height:  root.isHorizontal ? root.dotSize * 0.5 : 2
                    radius:  1
                    color:   Colors.foreground
                    opacity: 0.15
                    x: root.isHorizontal
                        ? wsDelegate.width + (root.wsSpacing - width) / 2
                        : (wsDelegate.width - width) / 2
                    y: root.isHorizontal
                        ? (wsDelegate.height - height) / 2
                        : wsDelegate.height + (root.wsSpacing - height) / 2
                }
            }
        }
    }
}
