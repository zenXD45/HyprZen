import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

Item {
    anchors.fill: parent
    opacity: root.displayState === 15 ? 1 : 0
    visible: opacity > 0
    clip: true
    Behavior on opacity {
        NumberAnimation { duration: root.displayState === 15 ? 240 : 160; easing.type: Easing.OutCubic }
    }

    Text {
        anchors.top: parent.top
        anchors.topMargin: 8
        anchors.horizontalCenter: parent.horizontalCenter
        text: "Clipboard Manager"
        color: "#EEEEF0"
        font.family: "Outfit"
        font.pixelSize: 11
        font.weight: Font.DemiBold
    }

    ColumnLayout {
        width: 740
        height: 166
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 26
        spacing: 12

        // ── Header / Search Bar ──
        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 340
            Layout.preferredHeight: 32
            radius: 16
            color: "#0AFFFFFF"

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 14
                anchors.rightMargin: 14
                spacing: 8

                Text {
                    text: "\uf0c5"
                    color: "#444448"
                    font.family: root.font
                    font.pixelSize: 12
                }

                TextInput {
                    id: clipSearchInput
                    Layout.fillWidth: true
                    color: "#EEEEF0"
                    font.family: "Outfit"
                    font.pixelSize: 12
                    verticalAlignment: TextInput.AlignVCenter
                    clip: true
                    focus: root.displayState === 15
                    focusPolicy: Qt.StrongFocus
                    onTextChanged: {
                        root.filterClipboard(text);
                        clipListView.currentIndex = 0;
                    }
                    Keys.onEscapePressed: {
                        root.displayState = 0; root.updateState(); text = "";
                    }
                    Keys.onLeftPressed: (event) => {
                        if (clipListView.currentIndex > 0) {
                            clipListView.currentIndex--;
                            clipListView.positionViewAtIndex(clipListView.currentIndex, ListView.Contain);
                        }
                        event.accepted = true;
                    }
                    Keys.onRightPressed: (event) => {
                        if (clipListView.currentIndex < clipboardModel.count - 1) {
                            clipListView.currentIndex++;
                            clipListView.positionViewAtIndex(clipListView.currentIndex, ListView.Contain);
                        }
                        event.accepted = true;
                    }
                    Keys.onReturnPressed: {
                        if (clipboardModel.count > 0) {
                            var targetIdx = (clipListView.currentIndex >= 0 && clipListView.currentIndex < clipboardModel.count) ? clipListView.currentIndex : 0;
                            var selectedItem = clipboardModel.get(targetIdx);
                            root.displayState = 0; root.updateState();
                            runCmd.command = ["python3", "/home/zen/.config/quickshell/dynamic-island/scripts/get_clipboard.py", "decode", selectedItem.id];
                            runCmd.running = true;
                            text = "";
                        }
                    }

                    Text {
                        anchors.fill: parent
                        verticalAlignment: Text.AlignVCenter
                        text: "Search clipboard..."
                        color: "#333338"
                        font.family: "Outfit"
                        font.pixelSize: 12
                        visible: !clipSearchInput.text && !clipSearchInput.activeFocus
                    }
                }
            }
        }

        // ── Clipboard Row ──
        ListView {
            id: clipListView
            property string hoveredItemId: ""
            Layout.fillWidth: true
            Layout.preferredHeight: 110
            orientation: ListView.Horizontal
            spacing: 8
            clip: true
            model: clipboardModel
            highlightMoveDuration: 200
            
            delegate: Rectangle {
                width: 140
                height: 110
                radius: 12
                color: (clipListView.currentIndex === index || clipListView.hoveredItemId === model.id) ? "#1AFFFFFF" : "#0AFFFFFF"
                border.color: (clipListView.currentIndex === index) ? "#44FFFFFF" : "transparent"
                border.width: 1

                Behavior on color { ColorAnimation { duration: 150 } }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 6

                    Item {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.preferredWidth: model.type === "image" ? 64 : 36
                        Layout.preferredHeight: model.type === "image" ? 64 : 36

                        Rectangle {
                            anchors.fill: parent
                            radius: 18
                            color: "#15FFFFFF"
                            visible: model.type !== "image"
                            
                            Text {
                                anchors.centerIn: parent
                                text: "\uf0c5"
                                color: "#EEEEF0"
                                font.family: root.font
                                font.pixelSize: 16
                            }
                        }

                        Rectangle {
                            id: maskRect
                            anchors.fill: parent
                            radius: 8
                            visible: false
                        }

                        Image {
                            anchors.fill: parent
                            source: model.type === "image" ? ("file://" + model.image_path) : ""
                            fillMode: Image.PreserveAspectCrop
                            visible: model.type === "image"
                            layer.enabled: true
                            layer.effect: OpacityMask {
                                maskSource: maskRect
                            }
                        }
                    }

                    Text {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        text: model.type === "image" ? "Image" : model.content
                        color: "#EEEEF0"
                        font.family: "Outfit"
                        font.pixelSize: 12
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.Wrap
                        elide: Text.ElideRight
                        maximumLineCount: model.type === "image" ? 1 : 3
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onEntered: clipListView.hoveredItemId = model.id
                    onExited: if (clipListView.hoveredItemId === model.id) clipListView.hoveredItemId = ""
                    onClicked: {
                        clipListView.currentIndex = index;
                        clipSearchInput.forceActiveFocus();
                        root.displayState = 0; root.updateState();
                        runCmd.command = ["python3", "/home/zen/.config/quickshell/dynamic-island/scripts/get_clipboard.py", "decode", model.id];
                        runCmd.running = true;
                        clipSearchInput.text = "";
                    }
                }
            }
        }
    }
}
