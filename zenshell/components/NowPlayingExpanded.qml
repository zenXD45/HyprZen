import QtQuick
import QtQuick.Layouts

ColumnLayout {
    anchors.fill: parent
    anchors.margins: 12
    spacing: 8
    opacity: (root.displayState === 1 && root.isExpanded) ? 1 : 0
    visible: opacity > 0

    Behavior on opacity { NumberAnimation { duration: (root.displayState === 1 && root.isExpanded) ? 240 : 160; easing.type: Easing.OutCubic } }

    RowLayout {
        Layout.fillWidth: true
        spacing: 10

        Rectangle {
            Layout.preferredWidth: 48
            Layout.preferredHeight: 48
            radius: 12
            color: "#25FFFFFF"
            clip: true

            Image { anchors.fill: parent; source: root.artUrl; fillMode: Image.PreserveAspectCrop; visible: status === Image.Ready }
            Text { anchors.centerIn: parent; text: "\uf001"; color: "#66FFFFFF"; font.family: root.font; font.pixelSize: 20; visible: root.artUrl === "" }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2
            Text { Layout.fillWidth: true; text: root.trackTitle || "Nothing Playing"; color: "#FFFFFF"; font.family: "Outfit"; font.pixelSize: 15; font.bold: true; elide: Text.ElideRight }
            Text { Layout.fillWidth: true; text: root.trackArtist || "Unknown"; color: "#99FFFFFF"; font.family: "Outfit"; font.pixelSize: 12; elide: Text.ElideRight }
        }
    }

    Item {
        Layout.fillWidth: true
        Layout.preferredHeight: 6
        Rectangle {
            anchors.fill: parent; radius: 3; color: "#25FFFFFF"
            Rectangle {
                width: root.trackLength > 0 ? Math.min(parent.width, parent.width * (root.trackPosition / root.trackLength)) : 0
                height: parent.height; radius: 3; color: "#FFFFFF"
                Behavior on width { NumberAnimation { duration: 1000; easing.type: Easing.Linear } }
            }
        }
    }

    RowLayout {
        Layout.fillWidth: true
        Text { text: root.formatTime(root.trackPosition); color: "#66FFFFFF"; font.family: "Outfit"; font.pixelSize: 10 }
        Item { Layout.fillWidth: true }
        Text { text: root.formatTime(root.trackLength); color: "#66FFFFFF"; font.family: "Outfit"; font.pixelSize: 10 }
    }

    Item { Layout.fillHeight: true }

    RowLayout {
        Layout.alignment: Qt.AlignHCenter
        spacing: 16

        Rectangle {
            id: prevBtn
            width: 34; height: 34; radius: 17
            color: prevArea.containsMouse ? "#22FFFFFF" : "transparent"
            property real btnScale: 1.0
            transform: Scale { origin.x: 17; origin.y: 17; xScale: prevBtn.btnScale; yScale: prevBtn.btnScale }
            Behavior on btnScale { NumberAnimation { duration: 200; easing.type: Easing.OutBack } }
            Text { anchors.centerIn: parent; text: "\uf04a"; color: "#FFFFFF"; font.family: root.font; font.pixelSize: 16 }
            MouseArea {
                id: prevArea; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                onPressed: prevBtn.btnScale = 0.88; onReleased: prevBtn.btnScale = 1.0; onClicked: root.prevTrack()
            }
        }
        Rectangle {
            id: playBtn
            width: 42; height: 42; radius: 21
            color: "#FFFFFF"
            property real btnScale: 1.0
            transform: Scale { origin.x: 21; origin.y: 21; xScale: playBtn.btnScale; yScale: playBtn.btnScale }
            Behavior on btnScale { NumberAnimation { duration: 200; easing.type: Easing.OutBack } }
            Text { anchors.centerIn: parent; text: root.isPlaying ? "\uf04c" : "\uf04b"; color: "#0D0D11"; font.family: root.font; font.pixelSize: 18 }
            MouseArea {
                anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                onPressed: playBtn.btnScale = 0.88; onReleased: playBtn.btnScale = 1.0; onClicked: root.playPause()
            }
        }
        Rectangle {
            id: nextBtn
            width: 34; height: 34; radius: 17
            color: nextArea.containsMouse ? "#22FFFFFF" : "transparent"
            property real btnScale: 1.0
            transform: Scale { origin.x: 17; origin.y: 17; xScale: nextBtn.btnScale; yScale: nextBtn.btnScale }
            Behavior on btnScale { NumberAnimation { duration: 200; easing.type: Easing.OutBack } }
            Text { anchors.centerIn: parent; text: "\uf04e"; color: "#FFFFFF"; font.family: root.font; font.pixelSize: 16 }
            MouseArea {
                id: nextArea; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                onPressed: nextBtn.btnScale = 0.88; onReleased: nextBtn.btnScale = 1.0; onClicked: root.nextTrack()
            }
        }
    }
}
