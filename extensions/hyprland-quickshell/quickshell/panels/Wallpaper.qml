// panels/Wallpaper.qml
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.globals
import qs.components
import qs.engine

Panel {
    id: wallPanel

    panelId:         "wallchange"
    panelWidth:      Style.panelWidth
    panelHeight:     Style.panelHeight
    animationPreset: "slide"
    keyboardFocus:   WlrKeyboardFocus.OnDemand

    FocusScope {
        id: wallRoot
        anchors.fill: parent

        property string searchQuery: ""
        // "all" | "images" | "videos"
        property string filterMode:  "all"

        Component.onCompleted: {
            WallpaperEngine.refresh()
            searchInput.forceActiveFocus()
        }

        ListModel { id: wallModel }

        function updateSearch() {
            wallModel.clear()

            let filtered = WallpaperEngine.wallpapers.filter(w => {
                let nameMatch = w.name.toLowerCase().includes(searchQuery.toLowerCase())
                let typeMatch = filterMode === "all"
                    || (filterMode === "videos" && w.video)
                    || (filterMode === "images" && !w.video)
                return nameMatch && typeMatch
            })

            for (let w of filtered)
                wallModel.append(w)

            wallGrid.currentIndex = 0
        }

        Connections {
            target: WallpaperEngine
            function onWallpapersChanged() { updateSearch() }
        }

        Column {
            anchors.fill: parent
            spacing: 10

            // ── Search bar ────────────────────────────────────────────────
            Rectangle {
                width: parent.width
                height: 36
                radius: 5
                color: Colors.color0

                border.width: searchInput.activeFocus ? 2 : 1
                border.color: searchInput.activeFocus ? Colors.color5 : Colors.color8

                TextInput {
                    id: searchInput
                    anchors.fill: parent
                    anchors.margins: 8

                    verticalAlignment: TextInput.AlignVCenter
                    color: Colors.foreground
                    font.family: Style.barFont
                    font.pixelSize: 14

                    onTextEdited: {
                        wallRoot.searchQuery = text
                        wallRoot.updateSearch()
                    }

                    onAccepted:     wallGrid.forceActiveFocus()

                    Keys.onDownPressed: (event) => {
                        wallGrid.forceActiveFocus()
                        wallGrid.currentIndex = 0
                        event.accepted = true
                    }
                    Keys.onEscapePressed: (event) => {
                        EventBus.togglePanel(wallPanel.panelId, null)
                        event.accepted = true
                    }

                    Text {
                        text:    " Search wallpapers…"
                        color:   Colors.color8
                        visible: !parent.text
                        font.family:    Style.barFont
                        font.pixelSize: 14
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }

            // ── Filter tabs ───────────────────────────────────────────────
            Row {
                spacing: 6

                Repeater {
                    model: [
                        { label: "All",    mode: "all"    },
                        { label: "󰋫  Images", mode: "images" },
                        { label: "󰕧  Videos", mode: "videos" }
                    ]

                    delegate: Rectangle {
                        required property var modelData
                        property bool active: wallRoot.filterMode === modelData.mode

                        height: 26
                        width:  labelText.implicitWidth + 20
                        radius: 4
                        color:  active
                            ? Colors.color5
                            : (tabMouse.containsMouse ? Colors.color0 : "transparent")
                        border.color: active ? "transparent" : Colors.color8
                        border.width: 1

                        Behavior on color { ColorAnimation { duration: 100 } }

                        Text {
                            id: labelText
                            anchors.centerIn: parent
                            text:             modelData.label
                            color:            active ? "white" : Colors.color8
                            font.family:      Style.barFont
                            font.pixelSize:   12
                        }

                        MouseArea {
                            id:           tabMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape:  Qt.PointingHandCursor
                            onClicked: {
                                wallRoot.filterMode = modelData.mode
                                wallRoot.updateSearch()
                            }
                        }
                    }
                }
            }

            // ── Grid ──────────────────────────────────────────────────────
            GridView {
                id: wallGrid
                width:  parent.width
                height: parent.height - 36 - 26 - 20   // search + tabs + spacing
                clip:   true

                property int columns: Math.max(2, Math.floor(width / 160))
                cellWidth:  width / columns
                cellHeight: cellWidth * 0.7

                model: wallModel
                focus: true
                currentIndex: 0

                Keys.onPressed: (event) => {
                    let cols = columns
                    if (event.key === Qt.Key_Right) {
                        currentIndex = Math.min(wallModel.count - 1, currentIndex + 1)
                        event.accepted = true
                    } else if (event.key === Qt.Key_Left) {
                        currentIndex = Math.max(0, currentIndex - 1)
                        event.accepted = true
                    } else if (event.key === Qt.Key_Down) {
                        currentIndex = Math.min(wallModel.count - 1, currentIndex + cols)
                        event.accepted = true
                    } else if (event.key === Qt.Key_Up) {
                        if (currentIndex < cols) {
                            searchInput.forceActiveFocus()
                        } else {
                            currentIndex = Math.max(0, currentIndex - cols)
                        }
                        event.accepted = true
                    } else if (event.key === Qt.Key_Return) {
                        let item = wallModel.get(currentIndex)
                        if (item) {
                            WallpaperEngine.apply(item.path)
                            EventBus.togglePanel(wallPanel.panelId, null)
                        }
                        event.accepted = true
                    } else if (event.key === Qt.Key_Escape) {
                        EventBus.togglePanel(wallPanel.panelId, null)
                        event.accepted = true
                    }
                }

                onCurrentIndexChanged: positionViewAtIndex(currentIndex, GridView.Visible)

                delegate: Item {
                    width:  wallGrid.cellWidth
                    height: wallGrid.cellHeight

                    Rectangle {
                        id: itemWrapper
                        anchors.fill:    parent
                        anchors.margins: 5
                        clip:            true
                        color:           Colors.color0

                        // ── Image preview (static/gif) ─────────────────
                        Image {
                            anchors.fill: parent
                            visible:      !model.video
                            source:       model.video ? "" : "file://" + model.path
                            fillMode:     Image.PreserveAspectCrop
                            smooth:       true
                            sourceSize:   Qt.size(250, 180)
                        }

                        // ── Video placeholder ──────────────────────────
                        Rectangle {
                            anchors.fill: parent
                            visible:      model.video
                            color:        Colors.color0

                            // Subtle gradient backdrop
                            Rectangle {
                                anchors.fill: parent
                                gradient: Gradient {
                                    orientation: Gradient.Vertical
                                    GradientStop { position: 0.0; color: Qt.rgba(Colors.color5.r, Colors.color5.g, Colors.color5.b, 0.25) }
                                    GradientStop { position: 1.0; color: "transparent" }
                                }
                            }

                            Column {
                                anchors.centerIn: parent
                                spacing: 4

                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text:           "󰕧"
                                    font.family:    Style.barFont
                                    font.pixelSize: itemWrapper.height * 0.35
                                    color:          Colors.color5
                                }

                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: {
                                        let ext = model.name.substring(model.name.lastIndexOf('.') + 1).toUpperCase()
                                        return ext
                                    }
                                    font.family:    Style.barFont
                                    font.pixelSize: 10
                                    color:          Colors.color8
                                }
                            }
                        }

                        // ── Name label ────────────────────────────────
                        Rectangle {
                            anchors.bottom: parent.bottom
                            width:          parent.width
                            height:         22
                            color:          Qt.rgba(0, 0, 0, 0.6)

                            Text {
                                anchors.centerIn: parent
                                text:             model.name
                                color:            "white"
                                font.family:      Style.barFont
                                font.pixelSize:   10
                                elide:            Text.ElideRight
                                width:            parent.width - 10
                            }
                        }

                        // ── Selection/hover border ─────────────────────
                        Rectangle {
                            anchors.fill:  parent
                            color:         "transparent"
                            border.width:  4
                            border.color: {
                                if (wallGrid.currentIndex === index)  return Colors.color5
                                if (delegateMouse.containsMouse)      return Colors.color13
                                return Qt.rgba(1, 1, 1, 0.1)
                            }
                        }

                        MouseArea {
                            id:           delegateMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                wallGrid.currentIndex = index
                                WallpaperEngine.apply(model.path)
                                EventBus.togglePanel(wallPanel.panelId, null)
                            }
                        }
                    }
                }
            }
        }
    }
}
