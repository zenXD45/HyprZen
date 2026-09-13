import QtQuick
import QtQuick.Layouts

Item {
    anchors.fill: parent
    opacity: root.displayState === 3 ? 1 : 0
    visible: opacity > 0
    clip: true
    Behavior on opacity {
        NumberAnimation { duration: root.displayState === 3 ? 240 : 160; easing.type: Easing.OutCubic }
    }

    ColumnLayout {
        width: 740
        height: 166
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 8
        spacing: 12

        // ── Search Bar ──
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
                    text: "\uf002"
                    color: "#444448"
                    font.family: root.font
                    font.pixelSize: 12
                }

                TextInput {
                    id: appSearchInput
                    Layout.fillWidth: true
                    color: "#EEEEF0"
                    font.family: "Outfit"
                    font.pixelSize: 12
                    verticalAlignment: TextInput.AlignVCenter
                    clip: true
                    focus: root.displayState === 3
                    focusPolicy: Qt.StrongFocus
                    onTextChanged: {
                        root.filterApps(text);
                        appListView.currentIndex = 0;
                    }
                    Keys.onEscapePressed: {
                        root.displayState = 0; root.updateState(); text = "";
                    }
                    Keys.onLeftPressed: (event) => {
                        if (appListView.currentIndex > 0) {
                            appListView.currentIndex--;
                            appListView.positionViewAtIndex(appListView.currentIndex, ListView.Contain);
                        }
                        event.accepted = true;
                    }
                    Keys.onRightPressed: (event) => {
                        if (appListView.currentIndex < appsModel.count - 1) {
                            appListView.currentIndex++;
                            appListView.positionViewAtIndex(appListView.currentIndex, ListView.Contain);
                        }
                        event.accepted = true;
                    }
                    Keys.onReturnPressed: {
                        if (appsModel.count > 0) {
                            var targetIdx = (appListView.currentIndex >= 0 && appListView.currentIndex < appsModel.count) ? appListView.currentIndex : 0;
                            var selectedApp = appsModel.get(targetIdx);
                            root.displayState = 0; root.updateState();
                            runCmd.command = ["bash", "-c", "gtk-launch " + selectedApp.exec + " > /dev/null 2>&1 || " + selectedApp.exec + " > /dev/null 2>&1 &"];
                            runCmd.running = true;
                            text = "";
                        }
                    }

                    Text {
                        anchors.fill: parent
                        verticalAlignment: Text.AlignVCenter
                        text: "Search apps..."
                        color: "#333338"
                        font.family: "Outfit"
                        font.pixelSize: 12
                        visible: !appSearchInput.text && !appSearchInput.activeFocus
                    }
                }
            }
        }

        // ── App Row ──
        ListView {
            id: appListView
            property string hoveredItemName: ""
            property real scrollAcc: 0
            currentIndex: 0
            Layout.fillWidth: true
            Layout.fillHeight: true
            orientation: ListView.Horizontal
            spacing: 6
            clip: true
            model: appsModel
            header: Item { width: 36; height: 1 }
            footer: Item { width: 36; height: 1 }

            MouseArea {
                anchors.fill: parent
                propagateComposedEvents: true
                onWheel: (wheel) => {
                    var delta = (wheel.angleDelta.y !== 0 ? wheel.angleDelta.y : wheel.angleDelta.x);
                    appListView.scrollAcc += delta;
                    if (Math.abs(appListView.scrollAcc) >= 60) {
                        if (appListView.scrollAcc < 0 && appListView.currentIndex < appsModel.count - 1) appListView.currentIndex++;
                        else if (appListView.scrollAcc > 0 && appListView.currentIndex > 0) appListView.currentIndex--;
                        appListView.positionViewAtIndex(appListView.currentIndex, ListView.Contain);
                        appListView.scrollAcc = 0;
                    }
                }
            }

            delegate: Item {
                width: 72
                height: ListView.view.height

                property bool isSel: index === appListView.currentIndex
                property bool isHov: appArea.containsMouse

                Rectangle {
                    id: appCard
                    anchors.fill: parent
                    anchors.margins: 2
                    radius: 18
                    color: isSel ? "#0CFFFFFF" : "transparent"
                    Behavior on color { ColorAnimation { duration: 200 } }

                    property real s: 1.0
                    transform: Scale { origin.x: appCard.width/2; origin.y: appCard.height/2; xScale: appCard.s; yScale: appCard.s }
                    Behavior on s { NumberAnimation { duration: 200; easing.type: Easing.OutBack } }

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 6

                        // Icon
                        Item {
                            Layout.preferredWidth: 44
                            Layout.preferredHeight: 44
                            Layout.alignment: Qt.AlignHCenter

                            Image {
                                id: appIconImg
                                anchors.centerIn: parent
                                width: isSel ? 44 : 38
                                height: width
                                source: (model.icon && model.icon.startsWith("/")) ? "file://" + model.icon : (model.icon ? "image://icon/" + model.icon : "")
                                sourceSize: Qt.size(44, 44)
                                asynchronous: true
                                opacity: isSel ? 1.0 : (isHov ? 0.8 : 0.5)

                                Behavior on width { NumberAnimation { duration: 200; easing.type: Easing.OutQuart } }
                                Behavior on opacity { NumberAnimation { duration: 200 } }
                            }

                            Text {
                                anchors.centerIn: parent
                                text: "\uf061"
                                color: "#444448"
                                font.family: root.font
                                font.pixelSize: 16
                                visible: appIconImg.status !== Image.Ready
                            }
                        }

                        // Name
                        Text {
                            Layout.fillWidth: true
                            Layout.maximumWidth: 68
                            horizontalAlignment: Text.AlignHCenter
                            text: model.name
                            color: isSel ? "#EEEEF0" : (isHov ? "#AAAAAA" : "#555558")
                            font.family: "Outfit"
                            font.pixelSize: 10
                            font.weight: isSel ? Font.DemiBold : Font.Normal
                            elide: Text.ElideRight
                            maximumLineCount: 1
                            Behavior on color { ColorAnimation { duration: 200 } }
                        }
                    }

                    // Accent underline
                    Rectangle {
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 2
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: isSel ? 18 : 0
                        height: 2
                        radius: 1
                        color: "#3B82F6"
                        Behavior on width { NumberAnimation { duration: 300; easing.type: Easing.OutQuart } }
                    }
                }

                MouseArea {
                    id: appArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onPressed: appCard.s = 0.9
                    onReleased: appCard.s = 1.0
                    onEntered: appListView.hoveredItemName = model.name
                    onExited: { if (appListView.hoveredItemName === model.name) appListView.hoveredItemName = "" }
                    onClicked: {
                        root.displayState = 0; root.updateState();
                        runCmd.command = ["bash", "-c", "gtk-launch " + model.exec + " > /dev/null 2>&1 || " + model.exec + " > /dev/null 2>&1 &"];
                        runCmd.running = true;
                    }
                }
            }
        }
    }
}
