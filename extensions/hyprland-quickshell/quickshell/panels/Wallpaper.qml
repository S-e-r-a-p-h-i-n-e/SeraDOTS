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

        Component.onCompleted: {
            WallpaperEngine.refresh()
            searchInput.forceActiveFocus()
        }

        ListModel { id: wallModel }

        function updateSearch() {
            wallModel.clear()

            let filtered = WallpaperEngine.wallpapers.filter(w =>
                w.name.toLowerCase().includes(searchQuery.toLowerCase())
            )

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
            spacing: 15

            // ── Search Bar ──────────────────────────────────────────────────
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
                    font.family: "JetBrains Mono"
                    font.pixelSize: 14

                    onTextEdited: {
                        searchQuery = text
                        updateSearch()
                    }

                    onAccepted: {
                        wallGrid.forceActiveFocus()
                    }

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
                        text: " Search Wallpapers..."
                        color: Colors.color8
                        visible: !parent.text
                        font.family: "JetBrains Mono"
                        font.pixelSize: 14
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }

            // ── Grid Container ──────────────────────────────────────────────
            Rectangle {
                width: parent.width
                height: parent.height - 60
                color: "transparent"

                GridView {
                    id: wallGrid
                    anchors.fill: parent

                    property int columns: Math.max(3, Math.floor(width / 160))

                    cellWidth: width / columns
                    cellHeight: cellWidth * 0.7

                    model: wallModel
                    clip: true

                    focus: true
                    currentIndex: 0

                    Keys.onPressed: (event) => {
                        let cols = columns

                        if (event.key === Qt.Key_Right) {
                            currentIndex = Math.min(wallModel.count - 1, currentIndex + 1)
                            event.accepted = true
                        }

                        else if (event.key === Qt.Key_Left) {
                            currentIndex = Math.max(0, currentIndex - 1)
                            event.accepted = true
                        }

                        else if (event.key === Qt.Key_Down) {
                            currentIndex = Math.min(wallModel.count - 1, currentIndex + cols)
                            event.accepted = true
                        }

                        else if (event.key === Qt.Key_Up) {
                            if (currentIndex < cols) {
                                searchInput.forceActiveFocus()
                            } else {
                                currentIndex = Math.max(0, currentIndex - cols)
                            }
                            event.accepted = true
                        }

                        else if (event.key === Qt.Key_Return) {
                            let item = wallModel.get(currentIndex)
                            if (item) {
                                WallpaperEngine.apply(item.path)
                                EventBus.togglePanel(wallPanel.panelId, null)
                            }
                            event.accepted = true
                        }

                        else if (event.key === Qt.Key_Escape) {
                            EventBus.togglePanel(wallPanel.panelId, null)
                            event.accepted = true
                        }
                    }

                    onCurrentIndexChanged: {
                        positionViewAtIndex(currentIndex, GridView.Visible)
                    }

                    delegate: Item {
                        width: wallGrid.cellWidth
                        height: wallGrid.cellHeight

                        Rectangle {
                            id: itemWrapper
                            anchors.fill: parent
                            anchors.margins: 5
                            radius: 0 
                            clip: true
                            color: Colors.color0

                            // 1. Image Layer
                            Image {
                                anchors.fill: parent
                                source: "file://" + model.path
                                fillMode: Image.PreserveAspectCrop
                                smooth: true
                                sourceSize: Qt.size(250, 180)
                            }

                            // 2. Label Overlay
                            Rectangle {
                                anchors.bottom: parent.bottom
                                width: parent.width
                                height: 22
                                color: Qt.rgba(0, 0, 0, 0.6)

                                Text {
                                    anchors.centerIn: parent
                                    text: model.name
                                    color: "white"
                                    font.family: "JetBrains Mono"
                                    font.pixelSize: 10
                                    elide: Text.ElideRight
                                    width: parent.width - 10
                                }
                            }

                            // 3. Border Overlay (Square & Thin)
                            Rectangle {
                                id: borderOverlay
                                anchors.fill: parent
                                radius: 0 
                                color: "transparent"
                                border.width: 4
                                border.color: {
                                    if (wallGrid.currentIndex === index) return Colors.color5;
                                    if (delegateMouse.containsMouse) return Colors.color13;
                                    return Qt.rgba(1, 1, 1, 0.1);
                                }
                            }

                            MouseArea {
                                id: delegateMouse
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
}