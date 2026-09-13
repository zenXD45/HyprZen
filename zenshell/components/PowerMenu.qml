import QtQuick
import QtQuick.Layouts
import Quickshell.Io

Item {
    anchors.fill: parent
    opacity: root.displayState === 12 ? 1 : 0
    visible: opacity > 0
    clip: true
    Behavior on opacity {
        NumberAnimation { duration: root.displayState === 12 ? 240 : 160; easing.type: Easing.OutCubic }
    }

    property int selectedIndex: 0

    Process {
        id: powerCmd
        command: []
    }

    function executeAction(idx) {
        var cmds = [
            "hyprlock",
            "systemctl suspend",
            "hyprctl dispatch exit",
            "systemctl reboot",
            "systemctl poweroff"
        ];
        if (idx >= 0 && idx < cmds.length) {
            root.displayState = 0;
            root.updateState();
            powerCmd.command = ["bash", "-c", cmds[idx]];
            powerCmd.running = true;
        }
    }

    FocusScope {
        anchors.fill: parent
        focus: root.displayState === 12
        Keys.onEscapePressed: { root.displayState = 0; root.updateState(); }
        Keys.onLeftPressed: (event) => { if (selectedIndex > 0) selectedIndex--; event.accepted = true; }
        Keys.onRightPressed: (event) => { if (selectedIndex < 4) selectedIndex++; event.accepted = true; }
        Keys.onReturnPressed: executeAction(selectedIndex)
        Keys.onPressed: (event) => {
            var keys = {"L": 0, "U": 1, "E": 2, "R": 3, "S": 4};
            var k = event.text.toUpperCase();
            if (k in keys) { selectedIndex = keys[k]; executeAction(keys[k]); event.accepted = true; }
        }
    }

    Text {
        anchors.top: parent.top
        anchors.topMargin: 8
        anchors.horizontalCenter: parent.horizontalCenter
        text: "Power Menu"
        color: "#EEEEF0"
        font.family: "Outfit"
        font.pixelSize: 11
        font.weight: Font.DemiBold
    }

    Row {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 10
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 14

        Repeater {
            model: [
                { icon: "\uf023", label: "Lock",     r: 0.376, g: 0.647, b: 0.980, key: "L" },
                { icon: "\uf186", label: "Suspend",  r: 0.655, g: 0.545, b: 0.980, key: "U" },
                { icon: "\uf2f5", label: "Logout",   r: 0.984, g: 0.749, b: 0.141, key: "E" },
                { icon: "\uf01e", label: "Reboot",   r: 0.204, g: 0.827, b: 0.600, key: "R" },
                { icon: "\uf011", label: "Shutdown", r: 0.973, g: 0.333, b: 0.333, key: "S" }
            ]

            Item {
                width: 76
                height: 96

                property bool isSel: index === selectedIndex
                property bool isHov: btnArea.containsMouse
                property color accentColor: root.currentThemeAccent || "#838996"

                // Card
                Rectangle {
                    id: card
                    anchors.fill: parent
                    radius: 20
                    color: "transparent"

                    property real s: 1.0
                    transform: Scale { origin.x: card.width/2; origin.y: card.height/2; xScale: card.s; yScale: card.s }
                    Behavior on s { NumberAnimation { duration: 220; easing.type: Easing.OutBack } }

                    // Glass background
                    Rectangle {
                        anchors.fill: parent
                        radius: 20
                        color: Qt.rgba(modelData.r, modelData.g, modelData.b, isSel ? 0.12 : (isHov ? 0.06 : 0.0))
                        Behavior on color { ColorAnimation { duration: 250 } }
                    }

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 10

                        // Glowing icon
                        Item {
                            Layout.preferredWidth: 36
                            Layout.preferredHeight: 36
                            Layout.alignment: Qt.AlignHCenter

                            // Glow behind icon
                            Rectangle {
                                anchors.centerIn: parent
                                width: isSel ? 32 : 0
                                height: width
                                radius: width / 2
                                color: Qt.rgba(modelData.r, modelData.g, modelData.b, 0.3)
                                opacity: isSel ? 1 : 0
                                Behavior on width { NumberAnimation { duration: 300; easing.type: Easing.OutQuart } }
                                Behavior on opacity { NumberAnimation { duration: 300 } }
                            }

                            Text {
                                anchors.centerIn: parent
                                text: modelData.icon
                                color: isSel ? accentColor : (isHov ? "#CCCCCC" : "#666666")
                                font.family: root.font
                                font.pixelSize: 20
                                Behavior on color { ColorAnimation { duration: 250 } }
                            }
                        }

                        // Label
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: modelData.label
                            color: isSel ? "#EEEEF0" : (isHov ? "#AAAAAA" : "#555558")
                            font.family: "Outfit"
                            font.pixelSize: 11
                            font.weight: isSel ? Font.DemiBold : Font.Medium
                            Behavior on color { ColorAnimation { duration: 250 } }
                        }
                    }

                    // Bottom accent line
                    Rectangle {
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 6
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: isSel ? 24 : 0
                        height: 2.5
                        radius: 1.25
                        color: accentColor
                        Behavior on width { NumberAnimation { duration: 300; easing.type: Easing.OutQuart } }
                    }

                    MouseArea {
                        id: btnArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onPressed: card.s = 0.88
                        onReleased: card.s = 1.0
                        onClicked: executeAction(index)
                        onEntered: selectedIndex = index
                    }
                }
            }
        }
    }
}