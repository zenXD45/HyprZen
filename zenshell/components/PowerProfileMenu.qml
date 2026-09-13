import QtQuick
import QtQuick.Layouts
import Quickshell.Io

Item {
    id: powerProfileMenu
    anchors.fill: parent
    opacity: root.displayState === 14 ? 1 : 0
    visible: opacity > 0
    clip: true
    Behavior on opacity {
        NumberAnimation { duration: root.displayState === 14 ? 240 : 160; easing.type: Easing.OutCubic }
    }

    property color themeAccent: root.currentThemeAccent || "#838996"
    property string activeProfile: "balanced"
    property int selectedIndex: 1

    Process {
        id: profileProc
        command: []
    }

    function setProfile(profile) {
        activeProfile = profile
        var cmd = ""
        if (profile === "performance") {
            cmd = "/home/zen/scripts/dell-gmode.sh set-perf"
        } else if (profile === "power-saver") {
            cmd = "/home/zen/scripts/dell-gmode.sh set-quiet"
        } else {
            cmd = "/home/zen/scripts/dell-gmode.sh set-balanced"
        }
        profileProc.running = false
        profileProc.command = ["bash", "-c", cmd]
        profileProc.running = true
        root.displayState = 0
        root.updateState()
    }

    Process {
        id: fetchActiveProfile
        command: ["powerprofilesctl", "get"]
        stdout: SplitParser {
            onRead: data => {
                var p = data.trim()
                if (p) {
                    activeProfile = p
                    if (p === "performance") selectedIndex = 0
                    else if (p === "balanced") selectedIndex = 1
                    else if (p === "power-saver") selectedIndex = 2
                }
            }
        }
    }

    onVisibleChanged: {
        if (visible) {
            fetchActiveProfile.running = true
        }
    }

    FocusScope {
        anchors.fill: parent
        focus: root.displayState === 14
        Keys.onEscapePressed: { root.displayState = 0; root.updateState(); }
        Keys.onLeftPressed: (event) => { if (selectedIndex > 0) selectedIndex--; event.accepted = true; }
        Keys.onRightPressed: (event) => { if (selectedIndex < 2) selectedIndex++; event.accepted = true; }
        Keys.onReturnPressed: {
            var profs = ["performance", "balanced", "power-saver"];
            setProfile(profs[selectedIndex]);
        }
        Keys.onPressed: (event) => {
            if (event.key === Qt.Key_1) { selectedIndex = 0; setProfile("performance"); event.accepted = true; }
            else if (event.key === Qt.Key_2) { selectedIndex = 1; setProfile("balanced"); event.accepted = true; }
            else if (event.key === Qt.Key_3) { selectedIndex = 2; setProfile("power-saver"); event.accepted = true; }
        }
    }

    Text {
        anchors.top: parent.top
        anchors.topMargin: 8
        anchors.horizontalCenter: parent.horizontalCenter
        text: "Power Profile"
        color: "#EEEEF0"
        font.family: "Outfit"
        font.pixelSize: 11
        font.weight: Font.DemiBold
    }

    Row {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 8
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 12

        Repeater {
            model: [
                { id: "performance", icon: "\uf135", label: "Performance", sub: "G-Mode • Max Speed", key: "1" },
                { id: "balanced",    icon: "\uf240", label: "Balanced",    sub: "Auto Fans • Normal", key: "2" },
                { id: "power-saver", icon: "\uf06c", label: "Power Saver", sub: "Quiet • Battery",   key: "3" }
            ]

            Item {
                width: 140
                height: 96

                property bool isSel: index === selectedIndex
                property bool isActive: activeProfile === modelData.id
                property bool isHov: btnArea.containsMouse

                Rectangle {
                    id: card
                    anchors.fill: parent
                    radius: 18
                    color: isActive ? Qt.rgba(themeAccent.r, themeAccent.g, themeAccent.b, 0.16) : (isHov ? "#0CFFFFFF" : "#06FFFFFF")
                    border.color: isSel ? themeAccent : (isActive ? Qt.rgba(themeAccent.r, themeAccent.g, themeAccent.b, 0.4) : "#10FFFFFF")
                    border.width: (isSel || isActive) ? 1.5 : 1

                    Behavior on color { ColorAnimation { duration: 200 } }
                    Behavior on border.color { ColorAnimation { duration: 200 } }

                    property real s: 1.0
                    transform: Scale { origin.x: card.width/2; origin.y: card.height/2; xScale: card.s; yScale: card.s }
                    Behavior on s { NumberAnimation { duration: 180; easing.type: Easing.OutBack } }

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 6

                        Item {
                            Layout.preferredWidth: 32
                            Layout.preferredHeight: 32
                            Layout.alignment: Qt.AlignHCenter

                            Rectangle {
                                anchors.centerIn: parent
                                width: isActive ? 28 : 0
                                height: width
                                radius: width / 2
                                color: Qt.rgba(themeAccent.r, themeAccent.g, themeAccent.b, 0.3)
                                opacity: isActive ? 1 : 0
                                Behavior on width { NumberAnimation { duration: 250; easing.type: Easing.OutQuart } }
                                Behavior on opacity { NumberAnimation { duration: 250 } }
                            }

                            Text {
                                anchors.centerIn: parent
                                text: modelData.icon
                                color: isActive ? themeAccent : (isHov ? "#EEEEF0" : "#666668")
                                font.family: root.font
                                font.pixelSize: 18
                                Behavior on color { ColorAnimation { duration: 200 } }
                            }
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: modelData.label
                            color: isActive ? "#FFFFFF" : (isHov ? "#CCCCCC" : "#888888")
                            font.family: "Outfit"
                            font.pixelSize: 11
                            font.weight: isActive ? Font.Bold : Font.Medium
                            Behavior on color { ColorAnimation { duration: 200 } }
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: modelData.sub
                            color: "#555558"
                            font.family: "Outfit"
                            font.pixelSize: 8
                        }
                    }

                    // Bottom accent line
                    Rectangle {
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 6
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: isActive ? 24 : (isSel ? 12 : 0)
                        height: 2
                        radius: 1
                        color: themeAccent
                        Behavior on width { NumberAnimation { duration: 250; easing.type: Easing.OutQuart } }
                    }

                    MouseArea {
                        id: btnArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onPressed: card.s = 0.90
                        onReleased: card.s = 1.0
                        onClicked: setProfile(modelData.id)
                        onEntered: selectedIndex = index
                    }
                }
            }
        }
    }
}
