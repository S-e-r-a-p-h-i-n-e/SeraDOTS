// modules/cliphist/ClipHist.qml
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.globals
import qs.components
import qs.engine

Panel {
    id: clipboardPanel

    panelId:         "clipboard"
    panelWidth:      Style.panelWidth
    panelHeight:     Style.panelHeight
    animationPreset: "slide"
    keyboardFocus:   WlrKeyboardFocus.OnDemand

    Item {
        id: clipRoot
        anchors.fill: parent

        property string searchQuery: ""
        property int selectedIndex: 0
        property bool showFavorites: false // Toggles between History and Favs

        Component.onCompleted: focusTimer.restart()
        onSearchQueryChanged: updateSearch()
        onShowFavoritesChanged: updateSearch()

        Connections {
            target: ClipboardEngine
            function onHistoryChanged() { clipRoot.updateSearch() }
            function onFavoritesChanged() { clipRoot.updateSearch() }
        }

        ListModel { id: clipModel }

        Connections {
            target: clipboardPanel
            function onShowPanelChanged() {
                if (clipboardPanel.showPanel) {
                    searchInput.text = ""
                    clipRoot.searchQuery = ""
                    clipRoot.selectedIndex = 0
                    clipRoot.showFavorites = false
                    searchInput.forceActiveFocus()
                    focusTimer.restart()
                    ClipboardEngine.refresh()
                } else {
                    searchInput.focus = false
                }
            }
        }

        Timer {
            id: focusTimer
            interval: 15
            onTriggered: searchInput.forceActiveFocus()
        }

        function fuzzyMatch(str, pattern) {
            if (!pattern) return true;
            pattern = pattern.toLowerCase().replace(/\s+/g, "")
            str = str.toLowerCase()
            let patternIdx = 0
            for (let i = 0; i < str.length && patternIdx < pattern.length; i++) {
                if (str[i] === pattern[patternIdx]) patternIdx++
            }
            return patternIdx === pattern.length
        }

        function updateSearch() {
            clipModel.clear();
            let sourceArray = clipRoot.showFavorites ? ClipboardEngine.favorites : ClipboardEngine.history;
            
            let filtered = sourceArray.filter(item => {
                // Favorites are raw strings, History are objects {id, content}
                let textToMatch = clipRoot.showFavorites ? item : item.content;
                return clipRoot.fuzzyMatch(textToMatch, clipRoot.searchQuery);
            });

            let batched = filtered.map(item => ({
                "clipId": clipRoot.showFavorites ? "" : item.id,
                "clipContent": clipRoot.showFavorites ? item : item.content
            }));

            if (batched.length > 0) clipModel.append(batched);
            clipRoot.selectedIndex = 0;
        }

        function executeSelected() {
            if (clipModel.count === 0) return;
            let item = clipModel.get(clipRoot.selectedIndex);
            
            if (clipRoot.showFavorites) {
                ClipboardEngine.copyFavorite(item.clipContent);
            } else {
                ClipboardEngine.copyHistory(item.clipId);
            }
            EventBus.togglePanel(clipboardPanel.panelId, null);
        }

        Column {
            anchors.fill: parent
            spacing: 10

            // --- Header & Search Bar ---
            Row {
                width: parent.width
                spacing: 10

                // Search Box
                Rectangle {
                    width: parent.width - wipeBtn.width - favBtn.width - 20
                    height: 36
                    color: Colors.color0
                    border.color: Colors.color8
                    border.width: 1
                    radius: 5

                    TextInput {
                        id: searchInput
                        anchors.fill: parent
                        anchors.margins: 8
                        verticalAlignment: TextInput.AlignVCenter
                        color: Colors.foreground
                        font.family: "JetBrains Mono"
                        font.pixelSize: 14
                        focus: true
                        
                        onTextEdited: clipRoot.searchQuery = text
                        
                        Text {
                            text: clipRoot.showFavorites ? "🌟 Search Favorites..." : " Search Clipboard..."
                            color: Colors.color8
                            visible: !parent.text
                            font.family: "JetBrains Mono"
                            font.pixelSize: 14
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Keys.onDownPressed: {
                            clipRoot.selectedIndex = Math.min(clipRoot.selectedIndex + 1, clipModel.count - 1)
                            clipList.positionViewAtIndex(clipRoot.selectedIndex, ListView.Contain)
                        }
                        Keys.onUpPressed: {
                            clipRoot.selectedIndex = Math.max(clipRoot.selectedIndex - 1, 0)
                            clipList.positionViewAtIndex(clipRoot.selectedIndex, ListView.Contain)
                        }
                        Keys.onReturnPressed: clipRoot.executeSelected()
                        Keys.onEscapePressed: EventBus.togglePanel(clipboardPanel.panelId, null)
                    }
                }

                // Toggle Favorites Button
                Rectangle {
                    id: favBtn
                    width: 36; height: 36; radius: 5
                    color: clipRoot.showFavorites ? Colors.color3 : Colors.color0
                    border.color: Colors.color8; border.width: 1
                    Text { anchors.centerIn: parent; text: "🌟"; font.pixelSize: 14 }
                    MouseArea {
                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            clipRoot.showFavorites = !clipRoot.showFavorites
                            searchInput.forceActiveFocus()
                        }
                    }
                }

                // Wipe History Button
                Rectangle {
                    id: wipeBtn
                    width: 36; height: 36; radius: 5
                    color: Colors.color1 // Red accent from your palette
                    border.color: Colors.color8; border.width: 1
                    visible: !clipRoot.showFavorites
                    Text { anchors.centerIn: parent; text: "🗑️"; font.pixelSize: 14 }
                    MouseArea {
                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        onClicked: ClipboardEngine.wipe()
                    }
                }
            }

            Rectangle { width: parent.width; height: 1; color: Colors.color8; opacity: 0.5 }

            // --- List View ---
            ListView {
                id: clipList
                width: parent.width
                height: parent.height - 50 
                clip: true
                spacing: 2
                model: clipModel

                delegate: Rectangle {
                    width: clipList.width
                    height: 45
                    radius: 5
                    
                    property bool isSelected: index === clipRoot.selectedIndex
                    color: isSelected ? Colors.color5 : (clipMouse.containsMouse ? Colors.color13 : "transparent")

                    Row {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 10
                        
                        Text {
                            width: parent.width - actionRow.width - 20
                            text: model.clipContent.replace(/\n/g, " ↵ ") // Flatten multi-line text for preview
                            color: isSelected ? "white" : clipMouse.containsMouse ? "white" : Colors.foreground
                            font.family: "JetBrains Mono"
                            font.pixelSize: 14
                            anchors.verticalCenter: parent.verticalCenter
                            elide: Text.ElideRight
                        }

                        // Inline Action Buttons
                        Row {
                            id: actionRow
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 8
                            visible: isSelected || clipMouse.containsMouse

                            // Star / Unstar Button
                            Text {
                                text: clipRoot.showFavorites ? "❌" : "➕"
                                font.pixelSize: 14
                                MouseArea {
                                    anchors.fill: parent; anchors.margins: -5; cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (clipRoot.showFavorites) {
                                            ClipboardEngine.removeFavorite(model.clipContent)
                                        } else {
                                            ClipboardEngine.addFavorite(model.clipId)
                                        }
                                    }
                                }
                            }
                        }
                    }

                    MouseArea {
                        id: clipMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        // We only want the main area to trigger a copy, not the inline buttons
                        onClicked: (mouse) => {
                            clipRoot.selectedIndex = index;
                            clipRoot.executeSelected();
                        }
                    }
                }
            }
        }
    }
}