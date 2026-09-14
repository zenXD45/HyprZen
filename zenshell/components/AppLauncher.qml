import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Item {
    id: launcher
    anchors.fill: parent
    opacity: root.displayState === 3 ? 1 : 0
    visible: opacity > 0
    clip: true
    Behavior on opacity {
        NumberAnimation { duration: root.displayState === 3 ? 220 : 160; easing.type: Easing.OutCubic }
    }

    property color themeAccent: root.currentThemeAccent || "#838996"
    property bool loading: false

    // ── Actions ─────────────────────────────────────────────────
    function runSearch() {
        loading = true;
        searchProc.command = ["python3", Quickshell.shellDir + "/scripts/get_search.py", searchInput.text.trim()];
        searchProc.running = true;
    }

    function shellQuote(s) {
        return "'" + String(s).replace(/'/g, "'\\''") + "'";
    }

    function launchEntry(modelItem) {
        root.displayState = 0; root.updateState();
        searchInput.text = "";
        if (modelItem.kind === "calc") {
            copyProc.command = ["bash", "-c", "printf %s " + shellQuote(modelItem.result) + " | wl-copy -n"];
            copyProc.running = true;
        } else if (modelItem.kind === "file") {
            runCmd.command = ["bash", "-c", "xdg-open " + shellQuote(modelItem.path) + " > /dev/null 2>&1 &"];
            runCmd.running = true;
        } else {
            runCmd.command = ["bash", "-c", "gtk-launch " + modelItem.exec + " > /dev/null 2>&1 || " + modelItem.exec + " > /dev/null 2>&1 &"];
            runCmd.running = true;
        }
    }

    // ── Search process (debounced) ───────────────────────────────
    ListModel { id: searchModel }

    Process {
        id: searchProc
        stdout: SplitParser {
            onRead: data => {
                loading = false;
                try {
                    var results = JSON.parse(data);
                    searchModel.clear();
                    for (var i = 0; i < results.length; i++) searchModel.append(results[i]);
                    resultList.currentIndex = searchModel.count > 0 ? 0 : -1;
                } catch(e) {
                    searchModel.clear();
                    resultList.currentIndex = -1;
                }
            }
        }
    }

    Process {
        id: copyProc
    }

    Timer {
        id: debounce
        interval: 180
        onTriggered: runSearch()
    }

    Component.onCompleted: runSearch()

    // ── Layout ───────────────────────────────────────────────────
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 12

        // ── Search Bar ──
        Rectangle {
            id: searchField
            Layout.fillWidth: true
            Layout.preferredHeight: 56
            radius: 22
            color: searchInput.activeFocus ? "#0D14FFFFFF" : "#0AFFFFFF"
            border.color: searchInput.activeFocus ? Qt.rgba(themeAccent.r, themeAccent.g, themeAccent.b, 0.45) : "#14FFFFFF"
            border.width: 1
            Behavior on color { ColorAnimation { duration: 180 } }
            Behavior on border.color { ColorAnimation { duration: 180 } }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 18
                anchors.rightMargin: 14
                spacing: 10

                // Magnifier — nudges onto the accent + scales on focus
                Text {
                    id: searchIcon
                    property real iconZoom: searchInput.activeFocus ? 1.08 : 1.0
                    text: "\uf002"
                    color: searchInput.activeFocus ? themeAccent : "#55555A"
                    font.family: root.font
                    font.pixelSize: 13
                    Behavior on color { ColorAnimation { duration: 180 } }
                    transform: Scale {
                        origin.x: width / 2; origin.y: height / 2
                        xScale: searchIcon.iconZoom
                        yScale: searchIcon.iconZoom
                    }
                    Behavior on iconZoom { NumberAnimation { duration: 220; easing.type: Easing.OutBack } }
                }

                TextInput {
                    id: searchInput
                    Layout.fillWidth: true
                    color: "#EEEEF0"
                    selectionColor: Qt.rgba(themeAccent.r, themeAccent.g, themeAccent.b, 0.4)
                    cursorColor: themeAccent
                    font.family: "Outfit"
                    font.pixelSize: 15
                    font.weight: Font.Medium
                    verticalAlignment: TextInput.AlignVCenter
                    clip: true
                    focus: root.displayState === 3
                    focusPolicy: Qt.StrongFocus
                    selectByMouse: true
                    onTextChanged: {
                        debounce.restart();
                    }
                    Keys.onEscapePressed: {
                        root.displayState = 0; root.updateState(); text = "";
                    }
                    Keys.onReturnPressed: {
                        if (searchModel.count > 0) {
                            var targetIdx = (resultList.currentIndex >= 0 && resultList.currentIndex < searchModel.count) ? resultList.currentIndex : 0;
                            launchEntry(searchModel.get(targetIdx));
                        }
                    }
                    Keys.onUpPressed: (event) => {
                        if (resultList.currentIndex > 0) {
                            resultList.currentIndex--;
                            resultList.positionViewAtIndex(resultList.currentIndex, ListView.Contain);
                        }
                        event.accepted = true;
                    }
                    Keys.onDownPressed: (event) => {
                        if (resultList.currentIndex < searchModel.count - 1) {
                            resultList.currentIndex++;
                            resultList.positionViewAtIndex(resultList.currentIndex, ListView.Contain);
                        }
                        event.accepted = true;
                    }
                    Keys.onLeftPressed: (event) => {
                        if (resultList.currentIndex > 0) {
                            resultList.currentIndex--;
                            resultList.positionViewAtIndex(resultList.currentIndex, ListView.Contain);
                        }
                        event.accepted = true;
                    }
                    Keys.onRightPressed: (event) => {
                        if (resultList.currentIndex < searchModel.count - 1) {
                            resultList.currentIndex++;
                            resultList.positionViewAtIndex(resultList.currentIndex, ListView.Contain);
                        }
                        event.accepted = true;
                    }

                    Text {
                        id: placeholderText
                        anchors.fill: parent
                        verticalAlignment: Text.AlignVCenter
                        text: "Search apps, files, and math\u2026"
                        color: "#59595F"
                        font.family: "Outfit"
                        font.pixelSize: 14
                        visible: !searchInput.text && !searchInput.activeFocus
                    }

                    // Right-side hint pill (esc)
                    Rectangle {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        width: 34; height: 22; radius: 11
                        color: "#0AFFFFFF"
                        border.color: "#14FFFFFF"
                        border.width: 1
                        visible: searchInput.activeFocus
                        Text {
                            anchors.centerIn: parent
                            text: "esc"
                            color: "#6A6A70"
                            font.family: root.font
                            font.pixelSize: 8
                        }
                    }
                }
            }

            // Loading sweep — thin accent bar gliding under the field
            Rectangle {
                id: loadingBar
                width: 110
                height: 2
                radius: 1
                y: searchField.height - 4
                x: -120
                color: Qt.rgba(themeAccent.r, themeAccent.g, themeAccent.b, 0.85)
                opacity: launcher.loading ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: 150 } }
                NumberAnimation on x {
                    running: launcher.loading
                    loops: Animation.Infinite
                    from: -120
                    to: searchField.width
                    duration: 900
                    easing.type: Easing.InOutQuad
                }
            }
        }

        // ── Results ──
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ListView {
                id: resultList
                anchors.fill: parent
                model: searchModel
                clip: true
                spacing: 6
                boundsBehavior: Flickable.StopAtBounds
                highlightFollowsCurrentItem: true
                highlightMoveDuration: 200
                highlightResizeDuration: 0
                currentIndex: -1

                highlight: Rectangle {
                    z: -1
                    radius: 16
                    color: Qt.rgba(launcher.themeAccent.r, launcher.themeAccent.g, launcher.themeAccent.b, 0.11)
                    border.color: Qt.rgba(launcher.themeAccent.r, launcher.themeAccent.g, launcher.themeAccent.b, 0.28)
                    border.width: 1
                }

                delegate: Item {
                    id: delegateRoot
                    required property var model
                    width: resultList.width
                    height: 60

                    property bool isHov: rowArea.containsMouse
                    property real press: 1.0
                    property real entryY: 14

                    opacity: 0
                    Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                    Behavior on entryY { NumberAnimation { duration: 260; easing.type: Easing.OutCubic } }
                    Behavior on press { NumberAnimation { duration: 120; easing.type: Easing.OutQuad } }

                    transform: [
                        Translate { y: delegateRoot.entryY },
                        Scale {
                            origin.x: width / 2
                            origin.y: height / 2
                            xScale: delegateRoot.press
                            yScale: delegateRoot.press
                        }
                    ]

                    Timer {
                        running: true
                        interval: Math.min(index * 24, 320)
                        repeat: false
                        onTriggered: {
                            delegateRoot.entryY = 0;
                            delegateRoot.opacity = 1;
                        }
                    }

                    Rectangle {
                        anchors.fill: parent
                        radius: 16
                        color: isHov && !(index === resultList.currentIndex) ? "#10FFFFFF" : "transparent"
                        border.color: "transparent"
                        Behavior on color { ColorAnimation { duration: 150 } }
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 14
                        spacing: 12

                        // Icon tile
                        Rectangle {
                            Layout.preferredWidth: 44
                            Layout.preferredHeight: 44
                            Layout.alignment: Qt.AlignVCenter
                            radius: 13
                            color: (index === resultList.currentIndex)
                                   ? Qt.rgba(launcher.themeAccent.r, launcher.themeAccent.g, launcher.themeAccent.b, 0.16)
                                   : "#1212140F"

                            Image {
                                id: rowIcon
                                anchors.centerIn: parent
                                width: 24
                                height: 24
                                source: (model.icon && model.icon.startsWith("/")) ? "file://" + model.icon : (model.icon ? "image://icon/" + model.icon : "")
                                sourceSize: Qt.size(44, 44)
                                asynchronous: true
                                visible: model.kind !== "calc" && rowIcon.status !== Image.Error && model.name !== ""
                            }

                            Text {
                                anchors.centerIn: parent
                                text: model.kind === "calc" ? "\uf1ec" : (model.kind === "file" ? "\uf016" : "\uf061")
                                color: (index === resultList.currentIndex) ? launcher.themeAccent : "#6A6A70"
                                font.family: root.font
                                font.pixelSize: 16
                                visible: model.kind === "calc" || model.kind === "file" || rowIcon.status !== Image.Ready || model.icon === ""
                            }
                        }

                        // Text
                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                            spacing: 2

                            Text {
                                Layout.fillWidth: true
                                text: model.name
                                color: (index === resultList.currentIndex)
                                       ? "#FFFFFF"
                                       : (isHov ? "#F0F0F2" : "#CFCFD4")
                                font.family: "Outfit"
                                font.pixelSize: 14
                                font.weight: (index === resultList.currentIndex) ? Font.DemiBold : Font.Normal
                                elide: Text.ElideRight
                                maximumLineCount: 1
                            }

                            Text {
                                Layout.fillWidth: true
                                text: model.sub || ""
                                color: "#8A8A90"
                                font.family: "Outfit"
                                font.pixelSize: 10
                                elide: Text.ElideRight
                                maximumLineCount: 1
                            }
                        }

                        // Kind tag
                        Text {
                            text: model.kind === "app" ? "\uf1c0" : (model.kind === "file" ? "\uf0c5" : (model.kind === "calc" ? "\uf1ec" : ""))
                            color: (index === resultList.currentIndex) ? launcher.themeAccent : "#484850"
                            font.family: root.font
                            font.pixelSize: 11
                        }
                    }

                    MouseArea {
                        id: rowArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onEntered: resultList.currentIndex = index
                        onPressed: delegateRoot.press = 0.97
                        onReleased: delegateRoot.press = 1.0
                        onCanceled: delegateRoot.press = 1.0
                        onClicked: launchEntry(model)
                    }
                }
            }

            // ── Empty state ──
            Rectangle {
                anchors.fill: parent
                radius: 16
                color: "transparent"
                visible: searchModel.count === 0 && !launcher.loading

                Column {
                    anchors.centerIn: parent
                    spacing: 10

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: searchInput.text.length === 0 ? "\uf002" : "\uf05e"
                        color: "#3A3A40"
                        font.family: root.font
                        font.pixelSize: 30
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: searchInput.text.length === 0 ? "Start typing to search" : "No results for \u201c" + searchInput.text.trim() + "\u201d"
                        color: "#77777C"
                        font.family: "Outfit"
                        font.pixelSize: 12
                        font.weight: Font.Medium
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Apps, files, and quick math"
                        color: "#4A4A50"
                        font.family: "Outfit"
                        font.pixelSize: 10
                    }
                }
            }
        }

        // ── Footer hints ──
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Text {
                text: searchModel.count + " results"
                color: "#55555A"
                font.family: root.font
                font.pixelSize: 9
                visible: searchModel.count > 0
            }

            Item { Layout.fillWidth: true }

            Text {
                text: "\u2191\u2193   navigate"
                color: "#4A4A50"
                font.family: root.font
                font.pixelSize: 9
            }

            Text {
                text: "\u2022"
                color: "#333338"
                font.family: root.font
                font.pixelSize: 9
            }

            Text {
                text: "\uf112   launch"
                color: "#4A4A50"
                font.family: root.font
                font.pixelSize: 9
            }

            Text {
                text: "\u2022"
                color: "#333338"
                font.family: root.font
                font.pixelSize: 9
            }

            Text {
                text: "esc   close"
                color: "#4A4A50"
                font.family: root.font
                font.pixelSize: 9
            }
        }
    }
}