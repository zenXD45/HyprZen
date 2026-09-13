import QtQuick
import QtQuick.Layouts

Item {
    anchors.fill: parent
    opacity: root.displayState === 11 ? 1 : 0
    visible: opacity > 0
    clip: true
    Behavior on opacity {
        NumberAnimation { duration: root.displayState === 11 ? 240 : 160; easing.type: Easing.OutCubic }
    }

    onVisibleChanged: {
        if (visible) {
            themeList.forceActiveFocus()
        }
    }

    Text {
        anchors.top: parent.top
        anchors.topMargin: 8
        anchors.horizontalCenter: parent.horizontalCenter
        text: "Theme Switcher"
        color: "#EEEEF0"
        font.family: "Outfit"
        font.pixelSize: 11
        font.weight: Font.DemiBold
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.topMargin: 26
        anchors.bottomMargin: 12
        anchors.leftMargin: 20
        anchors.rightMargin: 20
        spacing: 10

        // ── Theme Cards ──
        ListView {
            id: themeList
            Layout.fillWidth: true
            Layout.fillHeight: true
            orientation: ListView.Horizontal
            spacing: 10
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            currentIndex: 0
            property real scrollAcc: 0

            model: root.themesList.length

            focus: root.displayState === 11
            Keys.onEscapePressed: { root.displayState = 0; root.updateState(); }
            Keys.onLeftPressed: (event) => {
                if (themeList.currentIndex > 0) { themeList.currentIndex--; themeList.positionViewAtIndex(themeList.currentIndex, ListView.Contain); }
                event.accepted = true;
            }
            Keys.onRightPressed: (event) => {
                if (themeList.currentIndex < root.themesList.length - 1) { themeList.currentIndex++; themeList.positionViewAtIndex(themeList.currentIndex, ListView.Contain); }
                event.accepted = true;
            }
            Keys.onReturnPressed: {
                if (root.themesList.length > 0 && themeList.currentIndex >= 0 && themeList.currentIndex < root.themesList.length)
                    root.applyTheme(root.themesList[themeList.currentIndex].id);
            }

            MouseArea {
                anchors.fill: parent
                propagateComposedEvents: true
                onWheel: (wheel) => {
                    var delta = (wheel.angleDelta.y !== 0 ? wheel.angleDelta.y : wheel.angleDelta.x);
                    themeList.scrollAcc += delta;
                    if (Math.abs(themeList.scrollAcc) >= 60) {
                        if (themeList.scrollAcc < 0 && themeList.currentIndex < root.themesList.length - 1) themeList.currentIndex++;
                        else if (themeList.scrollAcc > 0 && themeList.currentIndex > 0) themeList.currentIndex--;
                        themeList.positionViewAtIndex(themeList.currentIndex, ListView.Contain);
                        themeList.scrollAcc = 0;
                    }
                }
            }

            delegate: Item {
                width: 80
                height: ListView.view.height

                property var theme: root.themesList[index] || {}
                property bool isActive: theme.id === root.currentThemeId
                property bool isSel: index === themeList.currentIndex
                property bool isHov: cardArea.containsMouse

                Rectangle {
                    id: card
                    anchors.fill: parent
                    radius: 14
                    color: "transparent"

                    property real s: 1.0
                    transform: Scale { origin.x: card.width/2; origin.y: card.height/2; xScale: card.s; yScale: card.s }
                    Behavior on s { NumberAnimation { duration: 220; easing.type: Easing.OutBack } }

                    // Glass background
                    Rectangle {
                        anchors.fill: parent
                        radius: 14
                        color: isSel || isHov ? "#0CFFFFFF" : "transparent"
                        Behavior on color { ColorAnimation { duration: 250 } }
                    }

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 6
                        spacing: 4

                        // Color palette preview
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 44
                            radius: 10
                            color: theme.bg || "#1e1e2e"
                            clip: true

                            // Accent gradient overlay
                            Rectangle {
                                anchors.fill: parent
                                radius: 10
                                gradient: Gradient {
                                    GradientStop { position: 0.0; color: "transparent" }
                                    GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, 0.5) }
                                }
                            }

                            // Emoji
                            Text {
                                anchors.centerIn: parent
                                anchors.verticalCenterOffset: -4
                                text: theme.icon || ""
                                font.pixelSize: 14
                            }

                            // Color dots
                            Row {
                                anchors.bottom: parent.bottom
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.bottomMargin: 4
                                spacing: 3

                                Repeater {
                                    model: [theme.accent, theme.extra, theme.fg, theme.surface]
                                    Rectangle {
                                        width: 6; height: 6; radius: 3
                                        color: modelData || "#888"
                                    }
                                }
                            }
                        }

                        // Name
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: theme.name || ""
                            color: isSel || isActive ? "#EEEEF0" : (isHov ? "#AAAAAA" : "#555558")
                            font.family: "Outfit"
                            font.pixelSize: 9
                            font.weight: isSel || isActive ? Font.DemiBold : Font.Medium
                            elide: Text.ElideRight
                            Layout.maximumWidth: card.width - 8
                            Behavior on color { ColorAnimation { duration: 250 } }
                        }

                        Item { Layout.fillHeight: true }
                    }

                    // Active accent underline
                    Rectangle {
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 4
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: isActive ? 20 : 0
                        height: 2.5
                        radius: 1.25
                        color: theme.accent || "#FFFFFF"
                        Behavior on width { NumberAnimation { duration: 300; easing.type: Easing.OutQuart } }
                    }

                    // Selection ring (keyboard focus)
                    Rectangle {
                        anchors.fill: parent
                        radius: 14
                        color: "transparent"
                        border.color: isSel ? "#30FFFFFF" : "transparent"
                        border.width: 1
                        Behavior on border.color { ColorAnimation { duration: 200 } }
                    }

                    MouseArea {
                        id: cardArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onPressed: card.s = 0.9
                        onReleased: card.s = 1.0
                        onClicked: root.applyTheme(theme.id)
                    }
                }
            }
        }
    }
}
