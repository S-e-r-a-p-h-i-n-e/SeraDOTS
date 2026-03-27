// panels/NotificationCard.qml — Individual notification toast card
import QtQuick
import Quickshell
import qs.globals
import qs.modules.notifications

Item {
    id: card

    property int    popupId:  0
    property string app:      ""
    property string summary:  ""
    property string body:     ""
    property string icon:     ""
    property int    urgency:  1   // 0=low 1=normal 2=critical
    property int    timeout:  5000  // ms, 0 = never

    // Height animates open/shut for smooth stack reflow
    implicitHeight: visible ? inner.height + 0 : 0
    clip: true

    Behavior on implicitHeight {
        NumberAnimation { duration: Animations.normal; easing.type: Animations.easeOut }
    }

    // ── Slide in from the right ────────────────────────────────────────────
    property bool shown: false

    Component.onCompleted: {
        shown = true
        if (card.timeout > 0) dismissTimer.restart()
    }

    // Listen for replacesId updates to reset the timer on this card
    Connections {
        target: Notifications
        function onPopupReplaced(oldId, newId) {
            if (card.popupId === newId && card.timeout > 0) {
                dismissTimer.restart()
                progressAnim.restart()
            }
        }
    }

    transform: Translate {
        x: card.shown ? 0 : 420
        Behavior on x {
            NumberAnimation { duration: Animations.normal; easing.type: Animations.easeOut }
        }
    }

    opacity: card.shown ? 1.0 : 0.0
    Behavior on opacity {
        NumberAnimation { duration: Animations.normal; easing.type: Animations.easeInOut }
    }

    // ── Dismiss logic ──────────────────────────────────────────────────────
    Timer {
        id: dismissTimer
        interval: card.timeout
        running:  false
        onTriggered: Notifications.dismissPopup(card.popupId)
    }

    // Pause timer while hovered
    onContainsMouseChanged: {
        if (card.timeout <= 0) return
        if (containsMouse) {
            dismissTimer.stop()
            progressAnim.pause()
        } else {
            // Resume remaining time proportionally
            const remaining = card.timeout * (1.0 - progressBar.progress)
            dismissTimer.interval = Math.max(remaining, 300)
            dismissTimer.restart()
            progressAnim.resume()
        }
    }

    property bool containsMouse: cardMouse.containsMouse

    // ── Card body ──────────────────────────────────────────────────────────
    Rectangle {
        id: inner
        width:  parent.width
        height: contentCol.implicitHeight + 20
        radius: 12

        // urgency colours: low=subtle, normal=panel bg, critical=red tint
        color: card.urgency === 2
               ? Qt.rgba(Colors.color1.r, Colors.color1.g, Colors.color1.b, 0.25)
               : Qt.rgba(Colors.background.r, Colors.background.g, Colors.background.b, 0.92)

        border.width: 1
        border.color: card.urgency === 2
                      ? Qt.rgba(Colors.color1.r, Colors.color1.g, Colors.color1.b, 0.7)
                      : cardMouse.containsMouse
                        ? Qt.rgba(Colors.foreground.r, Colors.foreground.g, Colors.foreground.b, 0.25)
                        : Qt.rgba(Colors.foreground.r, Colors.foreground.g, Colors.foreground.b, 0.10)

        Behavior on border.color { ColorAnimation { duration: Animations.fast } }

        // ── Content ──────────────────────────────────────────────────────
        Column {
            id: contentCol
            anchors { left: parent.left; right: parent.right; top: parent.top }
            anchors.margins: 14
            anchors.topMargin: 12
            spacing: 4

            // App name row + close button
            Row {
                width: parent.width
                spacing: 8

                // App icon (themed)
                Image {
                    width:   18; height: 18
                    source:  card.icon ? "image://icon/" + card.icon : ""
                    visible: card.icon !== "" && status === Image.Ready
                    anchors.verticalCenter: parent.verticalCenter
                    fillMode: Image.PreserveAspectFit
                }

                Text {
                    text:            card.app || "Notification"
                    color:           Qt.rgba(Colors.foreground.r, Colors.foreground.g, Colors.foreground.b, 0.55)
                    font.family:     Style.barFont
                    font.pixelSize:  11
                    font.weight:     Font.Medium
                    elide:           Text.ElideRight
                    width:           parent.width - closeBtn.width - 26
                    anchors.verticalCenter: parent.verticalCenter
                }

                // Close button
                Text {
                    id: closeBtn
                    text:           "✕"
                    color:          closeMouse.containsMouse
                                    ? Colors.foreground
                                    : Qt.rgba(Colors.foreground.r, Colors.foreground.g, Colors.foreground.b, 0.4)
                    font.pixelSize: 11
                    anchors.verticalCenter: parent.verticalCenter
                    Behavior on color { ColorAnimation { duration: Animations.fast } }

                    MouseArea {
                        id: closeMouse
                        anchors.fill:    parent
                        anchors.margins: -6
                        hoverEnabled:    true
                        cursorShape:     Qt.PointingHandCursor
                        onClicked:       Notifications.dismissPopup(card.popupId)
                    }
                }
            }

            // Summary
            Text {
                text:           card.summary
                color:          Colors.foreground
                font.family:    Style.barFont
                font.pixelSize: 13
                font.weight:    Font.SemiBold
                elide:          Text.ElideRight
                width:          parent.width
                visible:        card.summary !== ""
            }

            // Body
            Text {
                text:           card.body
                color:          Qt.rgba(Colors.foreground.r, Colors.foreground.g, Colors.foreground.b, 0.75)
                font.family:    Style.barFont
                font.pixelSize: 12
                wrapMode:       Text.WordWrap
                width:          parent.width
                visible:        card.body !== ""
                maximumLineCount: 4
                elide:          Text.ElideRight
            }
        }

        // ── Progress bar (auto-dismiss countdown) ─────────────────────────
        Rectangle {
            id: progressTrack
            anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
            anchors.margins: 0
            anchors.bottomMargin: 0
            height:  3
            radius:  12
            color:   Qt.rgba(Colors.foreground.r, Colors.foreground.g, Colors.foreground.b, 0.08)
            visible: card.timeout > 0
            clip:    true

            Rectangle {
                id: progressBar
                property real progress: 0.0   // 0.0 → 1.0 as time elapses
                anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
                width:  parent.width * (1.0 - progress)
                radius: parent.radius
                color:  card.urgency === 2
                        ? Colors.color1
                        : card.urgency === 0
                          ? Colors.color8
                          : Colors.color4

                NumberAnimation on progress {
                    id:        progressAnim
                    from:      0.0
                    to:        1.0
                    duration:  card.timeout
                    running:   card.timeout > 0
                }
            }
        }

        // ── Mouse area (hover to pause) ───────────────────────────────────
        // propagateComposedEvents: true so closeMouse inside the card can
        // still receive clicks — cardMouse only needs hover, not click capture.
        MouseArea {
            id: cardMouse
            anchors.fill: parent
            hoverEnabled: true
            propagateComposedEvents: true
            onClicked: (mouse) => { mouse.accepted = false }
        }
    }
}
