import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Qt5Compat.GraphicalEffects

Item {
    id: cheatsheetRoot
    anchors.fill: parent
    opacity: root.displayState === 23 ? 1 : 0
    visible: opacity > 0
    clip: true
    Behavior on opacity {
        NumberAnimation { duration: root.displayState === 23 ? 240 : 160; easing.type: Easing.OutCubic }
    }

    property var allBinds: []

    function filterBinds(query) {
        bindsModel.clear();
        var q = query.toLowerCase();
        for (var i = 0; i < allBinds.length; i++) {
            var b = allBinds[i];
            if (q === "" || b.key.toLowerCase().indexOf(q) !== -1 || b.action.toLowerCase().indexOf(q) !== -1 || b.category.toLowerCase().indexOf(q) !== -1) {
                bindsModel.append(b);
            }
        }
    }

    Text {
        anchors.top: parent.top
        anchors.topMargin: 8
        anchors.horizontalCenter: parent.horizontalCenter
        text: "Keybinds Cheatsheet"
        color: "#EEEEF0"
        font.family: "Outfit"
        font.pixelSize: 11
        font.weight: Font.DemiBold
    }

    ListModel {
        id: bindsModel
    }

    Process {
        id: fetchBinds
        command: ["/home/zen/.config/quickshell/dynamic-island/scripts/get_keybinds.py"]
        stdout: SplitParser {
            onRead: data => {
                try {
                    allBinds = JSON.parse(data.trim());
                    filterBinds(searchInput.text);
                } catch(e) {}
            }
        }
    }

    onVisibleChanged: {
        if (visible) {
            fetchBinds.running = true;
            searchInput.forceActiveFocus();
        }
    }

    ColumnLayout {
        width: 760
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 26
        anchors.bottomMargin: 10
        spacing: 8

        // ── Search Bar ──
        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 320
            Layout.preferredHeight: 28
            radius: 14
            color: "#08FFFFFF"
            border.color: searchInput.activeFocus ? "#25FFFFFF" : "transparent"
            border.width: 1

            Behavior on border.color { ColorAnimation { duration: 150 } }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                spacing: 8

                Text {
                    text: "\uf002"
                    color: searchInput.activeFocus ? "#EEEEF0" : "#55555A"
                    font.family: root.font
                    font.pixelSize: 11
                    Behavior on color { ColorAnimation { duration: 150 } }
                }

                TextInput {
                    id: searchInput
                    Layout.fillWidth: true
                    color: "#EEEEF0"
                    font.family: "Outfit"
                    font.pixelSize: 11
                    verticalAlignment: TextInput.AlignVCenter
                    clip: true
                    focus: root.displayState === 23
                    focusPolicy: Qt.StrongFocus
                    selectByMouse: true
                    
                    onTextChanged: {
                        filterBinds(text);
                        bindsList.currentIndex = 0;
                    }
                    Keys.onEscapePressed: {
                        root.displayState = 0; 
                        root.updateState(); 
                        text = "";
                    }
                    Keys.onDownPressed: (event) => {
                        if (bindsList.currentIndex < bindsModel.count - 1) {
                            bindsList.currentIndex++;
                            bindsList.positionViewAtIndex(bindsList.currentIndex, ListView.Contain);
                        }
                        event.accepted = true;
                    }
                    Keys.onUpPressed: (event) => {
                        if (bindsList.currentIndex > 0) {
                            bindsList.currentIndex--;
                            bindsList.positionViewAtIndex(bindsList.currentIndex, ListView.Contain);
                        }
                        event.accepted = true;
                    }
                }
            }
        }

        // ── List View ──
        ListView {
            id: bindsList
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: bindsModel
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            spacing: 0
            highlightMoveDuration: 150
            highlight: Rectangle {
                color: "#0AFFFFFF"
                radius: 4
            }
            highlightFollowsCurrentItem: true

            section.property: "category"
            section.delegate: Item {
                width: ListView.view.width
                height: 26
                
                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 6
                    anchors.rightMargin: 10
                    spacing: 8

                    Text {
                        text: section
                        color: "#707075"
                        font.pixelSize: 10
                        font.family: "Outfit"
                        font.weight: Font.DemiBold
                        font.capitalization: Font.AllUppercase
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: "#0AFFFFFF"
                    }
                }
            }

            delegate: Item {
                width: ListView.view.width
                height: 28

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 1
                    radius: 4
                    color: itemMouse.containsMouse && bindsList.currentIndex !== index ? "#05FFFFFF" : "transparent"
                    Behavior on color { ColorAnimation { duration: 100 } }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        spacing: 12

                        // Key combination styled as a badge
                        Rectangle {
                            Layout.preferredHeight: 18
                            Layout.preferredWidth: keyText.implicitWidth + 12
                            radius: 3
                            color: bindsList.currentIndex === index ? "#15FFFFFF" : "#121215"
                            border.color: bindsList.currentIndex === index ? "#30FFFFFF" : "#1AFFFFFF"
                            border.width: 1

                            Text {
                                id: keyText
                                anchors.centerIn: parent
                                text: model.key
                                color: bindsList.currentIndex === index ? "#FFFFFF" : "#C0C0C0"
                                font.family: "JetBrains Mono"
                                font.pixelSize: 9
                                font.weight: Font.DemiBold
                            }
                        }

                        // Action description
                        Text {
                            Layout.fillWidth: true
                            text: model.action
                            color: bindsList.currentIndex === index ? "#FFFFFF" : "#AAAAAA"
                            font.family: "Outfit"
                            font.pixelSize: 11
                            elide: Text.ElideRight
                        }
                    }

                    MouseArea {
                        id: itemMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            bindsList.currentIndex = index;
                        }
                        onDoubleClicked: {
                            root.displayState = 0; // Close on double click
                        }
                    }
                }
            }

            ScrollBar.vertical: ScrollBar {
                active: true
                policy: ScrollBar.AsNeeded
                contentItem: Rectangle {
                    implicitWidth: 3
                    radius: 1.5
                    color: "#30FFFFFF"
                }
            }
        }
    }
}
