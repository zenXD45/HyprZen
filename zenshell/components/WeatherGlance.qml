import QtQuick
import QtQuick.Layouts

Item {
    anchors.fill: parent
    opacity: root.displayState === 6 ? 1 : 0
    visible: opacity > 0
    clip: true
    Behavior on opacity { NumberAnimation { duration: root.displayState === 6 ? 240 : 160; easing.type: Easing.OutCubic } }

    RowLayout {
        anchors.centerIn: parent
        spacing: 12

        Text {
            text: root.weatherIcon
            font.pixelSize: 32
            Layout.alignment: Qt.AlignVCenter
        }

        ColumnLayout {
            Layout.alignment: Qt.AlignVCenter
            spacing: 2
            
            Text {
                text: root.weatherTemp
                color: "#FFFFFF"
                font.family: "Outfit"
                font.pixelSize: 22
                font.weight: Font.Bold
            }
            Text {
                text: root.weatherDesc
                color: "#A0A0A0"
                font.family: "Outfit"
                font.pixelSize: 13
                font.weight: Font.Medium
            }
        }
    }
}
