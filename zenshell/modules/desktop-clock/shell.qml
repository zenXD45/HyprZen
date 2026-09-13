import Quickshell
import QtQuick
import QtQuick.Layouts
import Quickshell.Io

Scope {
    id: root

    property bool clockVisible: true
    property var matugen: null
    property string currentTime: ""
    property string currentDate: ""
    property int currentHour: 0

    function col(name, fallback) {
        return matugen && matugen[name] !== undefined ? matugen[name] : fallback
    }

    function getGreeting(hour) {
        if (hour < 6) return "Good night, Zen"
        if (hour < 12) return "Good morning, Zen"
        if (hour < 17) return "Good afternoon, Zen"
        if (hour < 21) return "Good evening, Zen"
        return "Good night, Zen"
    }

    FileView {
        id: matugenFile
        path: Qt.resolvedUrl("/home/zen/.config/quickshell/matugen.json")
        onTextChanged: {
            try {
                root.matugen = JSON.parse(text)
            } catch (e) {
                root.matugen = null
            }
        }
    }

    Timer {
        id: matugenTimer
        interval: 5000
        running: true
        repeat: true
        onTriggered: matugenFile.reload()
        Component.onCompleted: triggered()
    }

    Timer {
        id: clockTimer
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            var d = new Date()
            root.currentTime = d.toLocaleTimeString(Qt.locale(), "hh:mm")
            root.currentDate = d.toLocaleDateString(Qt.locale(), "dddd, MMMM dd")
            root.currentHour = d.getHours()
        }
        Component.onCompleted: triggered()
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData
            screen: modelData

            visible: true
            color: "transparent"
            exclusionMode: ExclusionMode.Ignore
            anchors {
                top: true
                left: true
                right: true
            }

            width: 820
            height: 200
            margins.top: 140

            Item {
                anchors.fill: parent
                opacity: root.clockVisible ? 1 : 0

                Behavior on opacity {
                    NumberAnimation {
                        duration: 400
                        easing.type: Easing.OutCubic
                    }
                }

                Row {
                    anchors.centerIn: parent
                    spacing: 24

                    // — Time block —
                    Item {
                        width: timeText.width
                        height: timeText.height
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            text: root.currentTime
                            font.family: "Outfit"
                            font.pixelSize: 120
                            font.weight: Font.Black
                            color: "#000000"
                            opacity: 0.45
                            y: 5
                        }

                        Text {
                            id: timeText
                            text: root.currentTime
                            font.family: "Outfit"
                            font.pixelSize: 120
                            font.weight: Font.Black
                            color: "#ffffff"
                        }
                    }

                    // — Date + Greeting column —
                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 4

                        // Date
                        Item {
                            width: dateText.width
                            height: dateText.height

                            Text {
                                text: root.currentDate
                                font.family: "Outfit"
                                font.pixelSize: 32
                                font.weight: Font.Bold
                                color: "#000000"
                                opacity: 0.35
                                y: 2
                            }

                            Text {
                                id: dateText
                                text: root.currentDate
                                font.family: "Outfit"
                                font.pixelSize: 32
                                font.weight: Font.Bold
                                color: root.col("primary", "#c2c1ff")
                            }
                        }

                        // Greeting
                        Item {
                            width: greetingText.width
                            height: greetingText.height

                            Text {
                                text: root.getGreeting(root.currentHour)
                                font.family: "Outfit"
                                font.pixelSize: 20
                                color: "#000000"
                                opacity: 0.3
                                y: 2
                            }

                            Text {
                                id: greetingText
                                text: root.getGreeting(root.currentHour)
                                font.family: "Outfit"
                                font.pixelSize: 20
                                color: "#ffffffcc"
                            }
                        }
                    }
                }
            }
        }
    }

    IpcHandler {
        target: "clock"
        function toggle(): void { root.clockVisible = !root.clockVisible }
        function show(): void { root.clockVisible = true }
        function hide(): void { root.clockVisible = false }
    }
}
