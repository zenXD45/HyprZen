import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire

Item {
    id: controlPanel
    anchors.fill: parent
    opacity: root.displayState === 13 ? 1 : 0
    visible: opacity > 0
    clip: true
    Behavior on opacity {
        NumberAnimation { duration: root.displayState === 13 ? 240 : 160; easing.type: Easing.OutCubic }
    }

    // Dynamic Theme Accent
    property color themeAccent: root.currentThemeAccent || "#838996"

    // View Navigation: "main", "network", "bt"
    property string currentView: "main"

    // System States
    property bool wifiRadio: true
    property bool wiredActive: false
    property bool wifiActive: false
    property string activeType: "none"
    property string wiredConn: ""
    property string wifiConn: ""
    property string ipAddress: ""
    property var wifiNetworks: []

    property bool btPowered: false
    property var btDevices: []

    property bool caffeineEnabled: false
    property bool nightLightEnabled: false
    property bool micMuted: false
    property bool screenRecEnabled: false

    property real brightnessValue: 50
    property real volumeValue: 50

    property string connectingSsid: ""
    property string connectingMac: ""

    // Processes
    Process { id: execCmd; command: [] }

    function runShell(cmd) {
        execCmd.running = false
        execCmd.command = ["bash", "-c", cmd]
        execCmd.running = true
    }

    // Network Actions
    Process {
        id: netProc
        command: []
        stdout: SplitParser {
            onRead: data => {
                connectingSsid = ""
                try {
                    var st = JSON.parse(data.trim())
                    if (st.wired_active !== undefined) {
                        wiredActive = st.wired_active
                        wifiActive = st.wifi_active
                        wifiRadio = st.wifi_radio
                        activeType = st.active_type
                        wiredConn = st.wired_conn
                        wifiConn = st.wifi_conn
                        ipAddress = st.ip
                    }
                } catch(e) {}
            }
        }
    }

    Process {
        id: wifiListProc
        command: ["python3", "/home/zen/.config/quickshell/dynamic-island/scripts/network_ctl.py", "--wifi-list"]
        stdout: SplitParser {
            onRead: data => {
                try {
                    wifiNetworks = JSON.parse(data.trim())
                } catch(e) {}
            }
        }
    }

    function refreshNetwork() {
        netProc.command = ["python3", "/home/zen/.config/quickshell/dynamic-island/scripts/network_ctl.py", "--status"]
        netProc.running = true
        if (currentView === "network") {
            wifiListProc.running = true
        }
    }

    function switchWired() {
        netProc.command = ["python3", "/home/zen/.config/quickshell/dynamic-island/scripts/network_ctl.py", "--switch-wired"]
        netProc.running = true
    }

    function switchWifi() {
        netProc.command = ["python3", "/home/zen/.config/quickshell/dynamic-island/scripts/network_ctl.py", "--switch-wifi"]
        netProc.running = true
    }

    function toggleWifiRadio() {
        netProc.command = ["python3", "/home/zen/.config/quickshell/dynamic-island/scripts/network_ctl.py", "--toggle-wifi"]
        netProc.running = true
    }

    function connectWifi(ssid) {
        connectingSsid = ssid
        netProc.command = ["python3", "/home/zen/.config/quickshell/dynamic-island/scripts/network_ctl.py", "--connect-wifi", ssid]
        netProc.running = true
    }

    // Bluetooth Actions
    Process {
        id: btProc
        command: []
        stdout: SplitParser {
            onRead: data => {
                connectingMac = ""
                try {
                    var st = JSON.parse(data.trim())
                    if (st.powered !== undefined) btPowered = st.powered
                } catch(e) {}
            }
        }
    }

    Process {
        id: btDevProc
        command: ["python3", "/home/zen/.config/quickshell/dynamic-island/scripts/bluetooth_ctl.py", "--devices"]
        stdout: SplitParser {
            onRead: data => {
                connectingMac = ""
                try {
                    btDevices = JSON.parse(data.trim())
                } catch(e) {}
            }
        }
    }

    function refreshBluetooth() {
        btProc.command = ["python3", "/home/zen/.config/quickshell/dynamic-island/scripts/bluetooth_ctl.py", "--status"]
        btProc.running = true
        if (currentView === "bt") {
            btDevProc.running = true
        }
    }

    function toggleBluetooth() {
        btProc.command = ["python3", "/home/zen/.config/quickshell/dynamic-island/scripts/bluetooth_ctl.py", "--toggle"]
        btProc.running = true
    }

    function connectBtDevice(mac) {
        connectingMac = mac
        btDevProc.command = ["python3", "/home/zen/.config/quickshell/dynamic-island/scripts/bluetooth_ctl.py", "--connect", mac]
        btDevProc.running = true
    }

    // Sliders
    function setBrightness(val) {
        brightnessValue = Math.max(0, Math.min(100, val))
        runShell("brightnessctl s " + Math.round(brightnessValue) + "%")
    }

    function setVolume(val) {
        volumeValue = Math.max(0, Math.min(100, val))
        runShell("wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ " + (volumeValue / 100).toFixed(2))
    }

    // Toggles
    function toggleCaffeine() {
        caffeineEnabled = !caffeineEnabled;
        if (caffeineEnabled) {
            runShell("killall -STOP hypridle");
        } else {
            runShell("killall -CONT hypridle");
        }
    }

    function toggleNightLight() {
        nightLightEnabled = !nightLightEnabled
        runShell(nightLightEnabled ? "hyprsunset -t 4500 &" : "pkill hyprsunset")
    }

    function toggleMic() {
        micMuted = !micMuted;
        runShell("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle");
    }

    function toggleRecord() {
        Quickshell.execDetached(["gsr-ui", "launch-show"]);
        root.displayState = 0;
    }

    // Key escape
    FocusScope {
        anchors.fill: parent
        focus: root.displayState === 13
        Keys.onEscapePressed: {
            if (currentView !== "main") {
                currentView = "main"
            } else {
                root.displayState = 0
                root.updateState()
            }
        }
    }

    // Refresh on view change or launch & periodic timer
    Timer {
        id: initTimer
        interval: 180
        onTriggered: {
            refreshNetwork()
            refreshBluetooth()
            fetchBrightness.running = true
            fetchVolume.running = true
            fetchMic.running = true
        }
    }

    onVisibleChanged: {
        if (visible) {
            initTimer.restart()
        }
    }

    Timer {
        interval: 4000
        running: root.displayState === 13
        repeat: true
        onTriggered: {
            refreshNetwork()
            refreshBluetooth()
        }
    }

    Process {
        id: fetchBrightness
        command: ["bash", "-c", "echo $(( $(brightnessctl g) * 100 / $(brightnessctl m) ))"]
        stdout: SplitParser { onRead: data => { brightnessValue = parseInt(data.trim()) || 50 } }
    }

    Process {
        id: fetchVolume
        command: ["bash", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2*100)}'"]
        stdout: SplitParser { onRead: data => { volumeValue = parseInt(data.trim()) || 50 } }
    }

    Process {
        id: fetchMic
        command: ["bash", "-c", "wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | grep -q MUTED && echo '1' || echo '0'"]
        stdout: SplitParser { onRead: data => { micMuted = (data.trim() === '1') } }
    }

    // ════════════════════════════════════════════════════════════
    // ── MAIN VIEW ──
    // ════════════════════════════════════════════════════════════
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12
        visible: currentView === "main"

        // Header Bar
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Item {
                width: 28; height: 28
                Rectangle {
                    anchors.fill: parent
                    radius: 14
                    color: Qt.rgba(themeAccent.r, themeAccent.g, themeAccent.b, 0.15)
                    Text { anchors.centerIn: parent; text: "\uf013"; color: themeAccent; font.family: root.font; font.pixelSize: 13 }
                }
            }

            Text {
                text: "Control Center"
                color: "#FFFFFF"
                font.family: "Outfit"
                font.pixelSize: 15
                font.weight: Font.Bold
            }

            Item { Layout.fillWidth: true }

            // Active Connection Badge
            Rectangle {
                height: 22
                implicitWidth: badgeText.implicitWidth + 16
                radius: 11
                color: Qt.rgba(themeAccent.r, themeAccent.g, themeAccent.b, 0.15)
                border.color: Qt.rgba(themeAccent.r, themeAccent.g, themeAccent.b, 0.4)
                border.width: 1

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 4
                    Text {
                        text: activeType === "wired" ? "󰈀" : (wifiActive ? "\uf1eb" : "\uf072")
                        color: themeAccent
                        font.family: root.font
                        font.pixelSize: 10
                    }
                    Text {
                        id: badgeText
                        text: activeType === "wired" ? "Wired" : (wifiActive ? (wifiConn || "Wi-Fi") : "Offline")
                        color: "#EEEEF0"
                        font.family: "Outfit"
                        font.pixelSize: 10
                        font.weight: Font.Medium
                    }
                }
            }
        }

        // ── Primary Connectivity Cards (Network & Bluetooth) ──
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            // Network Card
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 64
                radius: 16
                color: (wifiRadio || wiredActive) ? Qt.rgba(themeAccent.r, themeAccent.g, themeAccent.b, 0.14) : "#0AFFFFFF"
                border.color: (wifiRadio || wiredActive) ? Qt.rgba(themeAccent.r, themeAccent.g, themeAccent.b, 0.35) : "#10FFFFFF"
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 10
                    spacing: 10

                    // Network Icon
                    Rectangle {
                        width: 38; height: 38; radius: 12
                        color: (wifiRadio || wiredActive) ? themeAccent : "#222226"
                        Text {
                            anchors.centerIn: parent
                            text: wiredActive ? "󰈀" : "\uf1eb"
                            color: (wifiRadio || wiredActive) ? "#0F0F14" : "#666666"
                            font.family: root.font
                            font.pixelSize: 16
                        }
                    }

                    // Label & Status
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        Text { text: "Network"; color: "#FFFFFF"; font.family: "Outfit"; font.pixelSize: 12; font.weight: Font.Bold }
                        Text {
                            text: wiredActive ? (wiredConn || "Ethernet") : (wifiRadio ? (wifiConn || "Disconnected") : "Disabled")
                            color: "#888899"
                            font.family: "Outfit"
                            font.pixelSize: 10
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                    }

                    // Expand Sub-View Button (>)
                    Rectangle {
                        width: 30; height: 30; radius: 10
                        color: netNavArea.containsMouse ? "#20FFFFFF" : "#0AFFFFFF"
                        Text { anchors.centerIn: parent; text: "\uf054"; color: "#AAAAAA"; font.family: root.font; font.pixelSize: 10 }
                        MouseArea {
                            id: netNavArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                currentView = "network"
                                refreshNetwork()
                            }
                        }
                    }
                }
            }

            // Bluetooth Card
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 64
                radius: 16
                color: btPowered ? Qt.rgba(themeAccent.r, themeAccent.g, themeAccent.b, 0.14) : "#0AFFFFFF"
                border.color: btPowered ? Qt.rgba(themeAccent.r, themeAccent.g, themeAccent.b, 0.35) : "#10FFFFFF"
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 10
                    spacing: 10

                    // BT Icon
                    Rectangle {
                        width: 38; height: 38; radius: 12
                        color: btPowered ? themeAccent : "#222226"
                        Text {
                            anchors.centerIn: parent
                            text: "\uf293"
                            color: btPowered ? "#0F0F14" : "#666666"
                            font.family: root.font
                            font.pixelSize: 16
                        }
                    }

                    // Label & Status
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        Text { text: "Bluetooth"; color: "#FFFFFF"; font.family: "Outfit"; font.pixelSize: 12; font.weight: Font.Bold }
                        Text {
                            text: btPowered ? (btDevices.length > 0 ? btDevices[0].name : "On") : "Off"
                            color: "#888899"
                            font.family: "Outfit"
                            font.pixelSize: 10
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                    }

                    // Expand Sub-View Button (>)
                    Rectangle {
                        width: 30; height: 30; radius: 10
                        color: btNavArea.containsMouse ? "#20FFFFFF" : "#0AFFFFFF"
                        Text { anchors.centerIn: parent; text: "\uf054"; color: "#AAAAAA"; font.family: root.font; font.pixelSize: 10 }
                        MouseArea {
                            id: btNavArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                currentView = "bt"
                                refreshBluetooth()
                            }
                        }
                    }
                }
            }
        }

        // ── Quick Toggles Grid (4 Action Buttons) ──
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Repeater {
                model: [
                    { id: "caffeine", icon: "\uf0f4", label: "Caffeine",    on: caffeineEnabled,     action: toggleCaffeine },
                    { id: "night",    icon: "\uf186", label: "Night Light", on: nightLightEnabled,  action: toggleNightLight },
                    { id: "mic",      icon: "\uf130", label: "Mute Mic",    on: micMuted,            action: toggleMic },
                    { id: "rec",      icon: "\uf03d", label: "Record",      on: screenRecEnabled,    action: toggleRecord }
                ]

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 46
                    radius: 12
                    color: modelData.on ? Qt.rgba(themeAccent.r, themeAccent.g, themeAccent.b, 0.18) : (qArea.containsMouse ? "#0CFFFFFF" : "#06FFFFFF")
                    border.color: modelData.on ? Qt.rgba(themeAccent.r, themeAccent.g, themeAccent.b, 0.4) : "transparent"
                    border.width: modelData.on ? 1 : 0

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 6
                        Text {
                            text: modelData.icon
                            color: modelData.on ? themeAccent : "#666666"
                            font.family: root.font
                            font.pixelSize: 14
                        }
                        Text {
                            text: modelData.label
                            color: modelData.on ? "#FFFFFF" : "#777777"
                            font.family: "Outfit"
                            font.pixelSize: 10
                            font.weight: modelData.on ? Font.Bold : Font.Medium
                        }
                    }

                    MouseArea {
                        id: qArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: modelData.action()
                    }
                }
            }
        }

        // ── Brightness & Volume Sliders ──
        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            // Brightness
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 38
                radius: 12
                color: "#08FFFFFF"

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    spacing: 8

                    Text { text: "\uf185"; color: themeAccent; font.family: root.font; font.pixelSize: 13 }

                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 20

                        Rectangle {
                            anchors.left: parent.left; anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                            height: 5; radius: 2.5; color: "#10FFFFFF"
                            Rectangle {
                                height: parent.height; radius: 2.5
                                width: parent.width * (brightnessValue / 100)
                                color: themeAccent
                            }
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            property bool dragging: false
                            onPressed: (mouse) => { dragging = true; setBrightness((mouse.x / parent.width) * 100) }
                            onReleased: dragging = false
                            onPositionChanged: (mouse) => { if (dragging) setBrightness((mouse.x / parent.width) * 100) }
                        }
                    }

                    Text { text: Math.round(brightnessValue) + "%"; color: "#888888"; font.family: "Outfit"; font.pixelSize: 10 }
                }
            }

            // Volume
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 38
                radius: 12
                color: "#08FFFFFF"

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    spacing: 8

                    Text { text: volumeValue === 0 ? "\uf6a9" : "\uf028"; color: themeAccent; font.family: root.font; font.pixelSize: 13 }

                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 20

                        Rectangle {
                            anchors.left: parent.left; anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                            height: 5; radius: 2.5; color: "#10FFFFFF"
                            Rectangle {
                                height: parent.height; radius: 2.5
                                width: parent.width * (volumeValue / 100)
                                color: themeAccent
                            }
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            property bool dragging: false
                            onPressed: (mouse) => { dragging = true; setVolume((mouse.x / parent.width) * 100) }
                            onReleased: dragging = false
                            onPositionChanged: (mouse) => { if (dragging) setVolume((mouse.x / parent.width) * 100) }
                        }
                    }

                    Text { text: Math.round(volumeValue) + "%"; color: "#888888"; font.family: "Outfit"; font.pixelSize: 10 }
                }
            }
        }

        // ── Integrated Notifications Section ──
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 8

            // Header
            RowLayout {
                Layout.fillWidth: true

                Text { text: "\uf0f3"; color: themeAccent; font.family: root.font; font.pixelSize: 12 }
                Text { text: "Notifications"; color: "#FFFFFF"; font.family: "Outfit"; font.pixelSize: 13; font.weight: Font.Bold }

                Item { Layout.fillWidth: true }

                Text {
                    text: root.notificationList.length > 0 ? root.notificationList.length + " new" : ""
                    color: themeAccent
                    font.family: "Outfit"
                    font.pixelSize: 10
                }

                Rectangle {
                    visible: root.notificationList.length > 0
                    height: 22
                    implicitWidth: 60
                    radius: 11
                    color: Qt.rgba(themeAccent.r, themeAccent.g, themeAccent.b, 0.15)
                    border.color: themeAccent
                    border.width: 1

                    Text { anchors.centerIn: parent; text: "Clear All"; color: "#EEEEF0"; font.family: "Outfit"; font.pixelSize: 9; font.weight: Font.Medium }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.clearAllNotifications()
                    }
                }
            }

            // Notification Cards or Empty Placeholder
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                // Empty state
                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 6
                    visible: root.notificationList.length === 0

                    Text { Layout.alignment: Qt.AlignHCenter; text: "\uf0f3"; color: "#22FFFFFF"; font.family: root.font; font.pixelSize: 24 }
                    Text { Layout.alignment: Qt.AlignHCenter; text: "No notifications"; color: "#444448"; font.family: "Outfit"; font.pixelSize: 11 }
                }

                // ListView
                ListView {
                    anchors.fill: parent
                    visible: root.notificationList.length > 0
                    model: (root.notificationList && root.notificationList.length) ? root.notificationList.length : 0
                    spacing: 6
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds

                    delegate: Rectangle {
                        width: ListView.view.width
                        height: 52
                        radius: 12
                        color: "#08FFFFFF"
                        border.color: "#10FFFFFF"
                        border.width: 1

                        property var notif: root.notificationList[index] || {}

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            spacing: 10

                            Rectangle {
                                width: 32; height: 32; radius: 8
                                color: Qt.rgba(themeAccent.r, themeAccent.g, themeAccent.b, 0.15)
                                Text { anchors.centerIn: parent; text: "\uf1d7"; color: themeAccent; font.family: root.font; font.pixelSize: 14 }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 1
                                Text { text: notif.appName || "Notification"; color: themeAccent; font.family: "Outfit"; font.pixelSize: 9; font.weight: Font.Bold }
                                Text { text: notif.summary || ""; color: "#FFFFFF"; font.family: "Outfit"; font.pixelSize: 11; font.weight: Font.SemiBold; elide: Text.ElideRight; Layout.fillWidth: true }
                                Text { text: notif.body || ""; color: "#888888"; font.family: "Outfit"; font.pixelSize: 10; elide: Text.ElideRight; Layout.fillWidth: true }
                            }

                            // Dismiss button
                            Rectangle {
                                width: 24; height: 24; radius: 6
                                color: dismissArea.containsMouse ? "#20EF4444" : "transparent"
                                Text { anchors.centerIn: parent; text: "\uf00d"; color: dismissArea.containsMouse ? "#EF4444" : "#555558"; font.family: root.font; font.pixelSize: 10 }
                                MouseArea {
                                    id: dismissArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.clearNotification(notif.id)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // ════════════════════════════════════════════════════════════
    // ── ADVANCED NETWORK & WI-FI SUB-VIEW ──
    // ════════════════════════════════════════════════════════════
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12
        visible: currentView === "network"

        // Sub-View Header
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Rectangle {
                width: 28; height: 28; radius: 10
                color: backNetArea.containsMouse ? "#20FFFFFF" : "#0AFFFFFF"
                Text { anchors.centerIn: parent; text: "\uf060"; color: "#FFFFFF"; font.family: root.font; font.pixelSize: 12 }
                MouseArea {
                    id: backNetArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: currentView = "main"
                }
            }

            Text { text: "Network & Wi-Fi"; color: "#FFFFFF"; font.family: "Outfit"; font.pixelSize: 15; font.weight: Font.Bold }

            Item { Layout.fillWidth: true }

            // Open Network Manager GUI
            Rectangle {
                width: 28; height: 28; radius: 10
                color: openNmArea.containsMouse ? "#20FFFFFF" : "#0AFFFFFF"
                Text { anchors.centerIn: parent; text: "\uf013"; color: "#888888"; font.family: root.font; font.pixelSize: 12 }
                MouseArea {
                    id: openNmArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: runShell("nm-connection-editor & || kitty -e nmtui &")
                }
            }

            // Refresh
            Rectangle {
                width: 28; height: 28; radius: 10
                color: refNetArea.containsMouse ? "#20FFFFFF" : "#0AFFFFFF"
                Text { anchors.centerIn: parent; text: "\uf021"; color: themeAccent; font.family: root.font; font.pixelSize: 12 }
                MouseArea {
                    id: refNetArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: refreshNetwork()
                }
            }
        }

        // ── Primary Switcher: Wired (Ethernet) vs Wi-Fi ──
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            // Wired Switcher Card
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 56
                radius: 14
                color: wiredActive ? Qt.rgba(themeAccent.r, themeAccent.g, themeAccent.b, 0.15) : "#08FFFFFF"
                border.color: wiredActive ? themeAccent : "#10FFFFFF"
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 10

                    Text { text: "󰈀"; color: wiredActive ? themeAccent : "#666666"; font.family: root.font; font.pixelSize: 18 }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        Text { text: "Wired Ethernet"; color: "#FFFFFF"; font.family: "Outfit"; font.pixelSize: 11; font.weight: Font.Bold }
                        Text { text: wiredActive ? (wiredConn || "Connected") : "Tap to Switch"; color: "#888888"; font.family: "Outfit"; font.pixelSize: 9 }
                    }

                    Rectangle {
                        width: 12; height: 12; radius: 6
                        color: wiredActive ? themeAccent : "#333338"
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: switchWired()
                }
            }

            // Wi-Fi Radio Card
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 56
                radius: 14
                color: wifiRadio ? Qt.rgba(themeAccent.r, themeAccent.g, themeAccent.b, 0.15) : "#08FFFFFF"
                border.color: wifiRadio ? themeAccent : "#10FFFFFF"
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 10

                    Text { text: "\uf1eb"; color: wifiRadio ? themeAccent : "#666666"; font.family: root.font; font.pixelSize: 18 }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        Text { text: "Wi-Fi Radio"; color: "#FFFFFF"; font.family: "Outfit"; font.pixelSize: 11; font.weight: Font.Bold }
                        Text { text: wifiRadio ? (wifiConn || "Enabled") : "Radio Off"; color: "#888888"; font.family: "Outfit"; font.pixelSize: 9 }
                    }

                    // Toggle Pill
                    Rectangle {
                        width: 32; height: 18; radius: 9
                        color: wifiRadio ? themeAccent : "#333338"
                        Rectangle {
                            width: 14; height: 14; radius: 7
                            x: wifiRadio ? 16 : 2
                            anchors.verticalCenter: parent.verticalCenter
                            color: "#FFFFFF"
                            Behavior on x { NumberAnimation { duration: 150 } }
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: toggleWifiRadio()
                }
            }
        }

        // ── Wi-Fi Networks List ──
        RowLayout {
            Layout.fillWidth: true
            Text { text: "AVAILABLE WI-FI NETWORKS"; color: "#555558"; font.family: "Outfit"; font.pixelSize: 10; font.weight: Font.Bold }
            Item { Layout.fillWidth: true }
            Text { text: "Tap network to connect"; color: "#444448"; font.family: "Outfit"; font.pixelSize: 9 }
        }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: (wifiNetworks && wifiNetworks.length) ? wifiNetworks.length : 0
            spacing: 6
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            delegate: Rectangle {
                width: ListView.view.width
                height: 44
                radius: 12
                color: itemNet.in_use ? Qt.rgba(themeAccent.r, themeAccent.g, themeAccent.b, 0.15) : (netItemArea.containsMouse ? "#0CFFFFFF" : "#06FFFFFF")
                border.color: itemNet.in_use ? themeAccent : "#10FFFFFF"
                border.width: itemNet.in_use ? 1 : 0

                property var itemNet: wifiNetworks[index] || {}
                property bool isConnecting: connectingSsid === itemNet.ssid

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 10

                    Text { text: "\uf1eb"; color: itemNet.in_use ? themeAccent : "#888888"; font.family: root.font; font.pixelSize: 14 }

                    Text { text: itemNet.ssid || "Hidden Network"; color: "#FFFFFF"; font.family: "Outfit"; font.pixelSize: 12; font.weight: itemNet.in_use ? Font.Bold : Font.Medium; Layout.fillWidth: true }

                    Text { text: isConnecting ? "Connecting..." : (itemNet.security || ""); color: isConnecting ? themeAccent : "#555558"; font.family: "Outfit"; font.pixelSize: 9 }

                    // Signal strength
                    Text {
                        text: itemNet.signal >= 75 ? "▂▄▆█" : (itemNet.signal >= 50 ? "▂▄▆_" : "▂▄__")
                        color: itemNet.in_use ? themeAccent : "#888888"
                        font.pixelSize: 10
                    }

                    // Connected check
                    Text { text: "\uf00c"; color: themeAccent; font.family: root.font; font.pixelSize: 12; visible: itemNet.in_use }
                }

                MouseArea {
                    id: netItemArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: connectWifi(itemNet.ssid)
                }
            }
        }
    }

    // ════════════════════════════════════════════════════════════
    // ── CUSTOM BLUETOOTH SUB-VIEW ──
    // ════════════════════════════════════════════════════════════
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12
        visible: currentView === "bt"

        // Sub-View Header
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Rectangle {
                width: 28; height: 28; radius: 10
                color: backBtArea.containsMouse ? "#20FFFFFF" : "#0AFFFFFF"
                Text { anchors.centerIn: parent; text: "\uf060"; color: "#FFFFFF"; font.family: root.font; font.pixelSize: 12 }
                MouseArea {
                    id: backBtArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: currentView = "main"
                }
            }

            Text { text: "Bluetooth Devices"; color: "#FFFFFF"; font.family: "Outfit"; font.pixelSize: 15; font.weight: Font.Bold }

            Item { Layout.fillWidth: true }

            // Open Bluetooth Manager GUI
            Rectangle {
                width: 28; height: 28; radius: 10
                color: openBtArea.containsMouse ? "#20FFFFFF" : "#0AFFFFFF"
                Text { anchors.centerIn: parent; text: "\uf013"; color: "#888888"; font.family: root.font; font.pixelSize: 12 }
                MouseArea {
                    id: openBtArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: runShell("blueman-manager &")
                }
            }

            // Refresh
            Rectangle {
                width: 28; height: 28; radius: 10
                color: refBtArea.containsMouse ? "#20FFFFFF" : "#0AFFFFFF"
                Text { anchors.centerIn: parent; text: "\uf021"; color: themeAccent; font.family: root.font; font.pixelSize: 12 }
                MouseArea {
                    id: refBtArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: refreshBluetooth()
                }
            }
        }

        // Power Toggle Card
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 48
            radius: 14
            color: btPowered ? Qt.rgba(themeAccent.r, themeAccent.g, themeAccent.b, 0.15) : "#08FFFFFF"
            border.color: btPowered ? themeAccent : "#10FFFFFF"
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                spacing: 10

                Text { text: "\uf293"; color: btPowered ? themeAccent : "#666666"; font.family: root.font; font.pixelSize: 16 }
                Text { text: "Bluetooth Adapter"; color: "#FFFFFF"; font.family: "Outfit"; font.pixelSize: 12; font.weight: Font.Bold; Layout.fillWidth: true }

                Rectangle {
                    width: 36; height: 20; radius: 10
                    color: btPowered ? themeAccent : "#333338"
                    Rectangle {
                        width: 16; height: 16; radius: 8
                        x: btPowered ? 18 : 2
                        anchors.verticalCenter: parent.verticalCenter
                        color: "#FFFFFF"
                        Behavior on x { NumberAnimation { duration: 150 } }
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: toggleBluetooth()
            }
        }

        Text { text: "PAIRED & NEARBY DEVICES"; color: "#555558"; font.family: "Outfit"; font.pixelSize: 10; font.weight: Font.Bold }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: (btDevices && btDevices.length) ? btDevices.length : 0
            spacing: 6
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            delegate: Rectangle {
                width: ListView.view.width
                height: 48
                radius: 12
                color: itemBt.connected ? Qt.rgba(themeAccent.r, themeAccent.g, themeAccent.b, 0.15) : (btItemArea.containsMouse ? "#0CFFFFFF" : "#06FFFFFF")
                border.color: itemBt.connected ? themeAccent : "#10FFFFFF"
                border.width: itemBt.connected ? 1 : 0

                property var itemBt: btDevices[index] || {}
                property bool isConnecting: connectingMac === itemBt.mac

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 10

                    Text {
                        text: itemBt.icon === "phone" ? "\uf10b" : (itemBt.icon === "audio-headset" ? "\uf025" : "\uf293")
                        color: itemBt.connected ? themeAccent : "#888888"
                        font.family: root.font
                        font.pixelSize: 16
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 1
                        Text { text: itemBt.name || "Bluetooth Device"; color: "#FFFFFF"; font.family: "Outfit"; font.pixelSize: 12; font.weight: itemBt.connected ? Font.Bold : Font.Medium }
                        Text { text: itemBt.mac || ""; color: "#555558"; font.family: "Outfit"; font.pixelSize: 9 }
                    }

                    Rectangle {
                        height: 24
                        implicitWidth: btText.implicitWidth + 16
                        radius: 12
                        color: itemBt.connected ? themeAccent : "#20FFFFFF"
                        Text {
                            id: btText
                            anchors.centerIn: parent
                            text: isConnecting ? "Working..." : (itemBt.connected ? "Disconnect" : "Connect")
                            color: "#FFFFFF"
                            font.family: "Outfit"
                            font.pixelSize: 10
                            font.weight: Font.Medium
                        }
                    }
                }

                MouseArea {
                    id: btItemArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: connectBtDevice(itemBt.mac)
                }
            }
        }
    }
}