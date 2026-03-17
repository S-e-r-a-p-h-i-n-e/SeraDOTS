// panels/Launcher.qml
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.globals   
import qs.components
import qs.engine

Panel {
    id: launcherPanel
    
    // Panel.qml specific properties
    panelId:         "launcher"
    panelWidth:      Style.panelWidth
    panelHeight:     Style.panelHeight
    animationPreset: "slide"
    keyboardFocus:   WlrKeyboardFocus.OnDemand 

    Item {
        id: launcherRoot
        anchors.fill: parent

        property string searchQuery: ""
        property int selectedIndex: 0

        Component.onCompleted: focusTimer.restart()
        onSearchQueryChanged: updateSearch()

        Connections {
            target: AppEngine
            function onApplicationsChanged() {
                launcherRoot.updateSearch()
            }
        }

        ListModel {
            id: appsModel
        }

        Connections {
            target: launcherPanel
            function onShowPanelChanged() {
                if (launcherPanel.showPanel) {
                    searchInput.text = ""
                    launcherRoot.searchQuery = ""
                    launcherRoot.selectedIndex = 0
                    searchInput.forceActiveFocus()
                    focusTimer.restart()
                    
                    if (AppEngine.applications.length === 0 && !AppEngine.loading) {
                        AppEngine.refresh()
                    } else {
                        launcherRoot.updateSearch()
                    }
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
            appsModel.clear();
            let filtered = [];
            
            if (launcherRoot.searchQuery.trim() === "") {
                filtered = AppEngine.applications;
            } else {
                filtered = AppEngine.applications.filter(app => launcherRoot.fuzzyMatch(app.name, launcherRoot.searchQuery));
            }

            let batchedApps = filtered.map(app => ({
                "appName": app.name,
                "appIcon": app.icon,
                "appExec": app.exec
            }));

            if (batchedApps.length > 0) {
                appsModel.append(batchedApps);
            }
            
            launcherRoot.selectedIndex = 0;
        }

        function launchSelected() {
            if (appsModel.count > 0 && launcherRoot.selectedIndex >= 0 && launcherRoot.selectedIndex < appsModel.count) {
                let cmd = appsModel.get(launcherRoot.selectedIndex).appExec;
                Quickshell.execDetached({ command: ["sh", "-c", cmd] });
                EventBus.togglePanel(launcherPanel.panelId);
            }
        }

        Column {
            anchors.fill: parent
            spacing: 10
            
            Rectangle {
                width: parent.width
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
                    
                    onTextEdited: launcherRoot.searchQuery = text
                    
                    Text {
                        text: AppEngine.loading ? "  Loading apps..." : "  Search apps..."
                        color: Colors.color8
                        visible: !parent.text
                        font.family: "JetBrains Mono"
                        font.pixelSize: 14
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: appsModel.count + " apps"
                        color: Colors.color8
                        font.family: "JetBrains Mono"
                        font.pixelSize: 12
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        visible: appsModel.count > 0
                    }
                    
                    Keys.onDownPressed: {
                        launcherRoot.selectedIndex = Math.min(launcherRoot.selectedIndex + 1, appsModel.count - 1)
                        appList.positionViewAtIndex(launcherRoot.selectedIndex, ListView.Contain)
                    }
                    Keys.onUpPressed: {
                        launcherRoot.selectedIndex = Math.max(launcherRoot.selectedIndex - 1, 0)
                        appList.positionViewAtIndex(launcherRoot.selectedIndex, ListView.Contain)
                    }
                    Keys.onReturnPressed: launcherRoot.launchSelected()
                    Keys.onEscapePressed: EventBus.togglePanel(launcherPanel.panelId)
                }
            }

            Rectangle { width: parent.width; height: 1; color: Colors.color8; opacity: 0.5 }

            ListView {
                id: appList
                width: parent.width
                height: parent.height - 50 
                clip: true
                spacing: 2
                model: appsModel

                delegate: Rectangle {
                    width: appList.width
                    height: 45
                    radius: 5
                    
                    property bool isSelected: index === launcherRoot.selectedIndex
                    
                    color: isSelected ? Colors.color5 : (appMouse.containsMouse ? Colors.color13 : "transparent")
                    
                    Rectangle {
                        anchors.bottom: parent.bottom
                        width: parent.width
                        height: 2
                        color: Colors.color13
                        visible: isSelected
                    }

                    Row {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 10
                        
                        Image {
                            width: 24; height: 24
                            anchors.verticalCenter: parent.verticalCenter
                            smooth: true
                            // Good practice to keep SVG scaling crisp:
                            sourceSize: Qt.size(24, 24) 
                            
                            // CHANGED: Logic to handle both named icons and absolute file paths
                            source: {
                                if (!model.appIcon) return "";
                                if (model.appIcon.startsWith("/")) {
                                    return "file://" + model.appIcon;
                                }
                                return "image://icon/" + model.appIcon;
                            }
                        }

                        Text {
                            text: model.appName
                            color: isSelected ? "white" : appMouse.containsMouse ? "white" : Colors.foreground
                            font.family: "JetBrains Mono"
                            font.weight: isSelected ? Font.Bold : Font.Normal
                            font.pixelSize: 14
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        id: appMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            launcherRoot.selectedIndex = index;
                            launcherRoot.launchSelected();
                        }
                    }
                }
            }
        }
    }
}