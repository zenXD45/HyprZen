import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Widgets
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Scope {
  id: root

  property bool isVisible: false
  property string currentQuery: ""
  
  signal requestFocus()

  IpcHandler {
    target: "qs-spotlight"
    function toggle(): void {
      root.isVisible = !root.isVisible;
      if (root.isVisible) {
        root.requestFocus();
      }
    }
    function show(): void {
      root.isVisible = true;
      root.requestFocus();
    }
    function hide(): void {
      root.isVisible = false;
    }
  }

  function launchResult(item) {
    if (item.type === "app") {
      var execStr = item.exec.replace(/%[a-zA-Z]/g, "");
      Hyprland.dispatch("hl.dsp.exec_cmd([[" + execStr + "]])");
    } else {
      if (item.icon === "text-x-generic" || item.icon === "text-x-script" || item.path.indexOf(".config") !== -1 || item.path.indexOf(".bashrc") !== -1) {
        Hyprland.dispatch("hl.dsp.exec_cmd([[kitty -e nvim '" + item.path + "']])");
      } else {
        Hyprland.dispatch("hl.dsp.exec_cmd([[xdg-open '" + item.path + "']])");
      }
    }
    root.isVisible = false;
    root.currentQuery = "";
    resultsModel.clear();
  }

  ListModel {
    id: resultsModel
  }

  Process {
    id: searchProc
    command: ["/home/zen/.config/quickshell/spotlight/search.py", root.currentQuery]
    running: false
    stdout: SplitParser {
      onRead: (data) => {
        try {
          var results = JSON.parse(data);
          resultsModel.clear();
          for (var i = 0; i < results.length; i++) {
            resultsModel.append(results[i]);
          }
          if (panel.resultListRef) {
            panel.resultListRef.currentIndex = 0;
          }
        } catch (e) {}
      }
    }
  }

  Timer {
    id: debounceTimer
    interval: 200
    repeat: false
    onTriggered: {
      if (root.currentQuery.length > 0) {
        searchProc.running = true;
      } else {
        resultsModel.clear();
      }
    }
  }

  onCurrentQueryChanged: {
    if (root.currentQuery.length === 0) {
      resultsModel.clear();
    }
    debounceTimer.restart();
  }

  Variants {
    model: [Quickshell.screens[0]]
    PanelWindow {
      id: panel
      required property var modelData
      screen: modelData
      
      property var resultListRef: resultList

      Connections {
        target: root
        function onRequestFocus() {
          searchInput.forceActiveFocus();
          searchInput.selectAll();
        }
      }

      implicitWidth: 700
      implicitHeight: 80 + (resultsModel.count > 0 ? (Math.min(resultsModel.count, 7) * 60 + 34) : 0)
      
      visible: root.isVisible
      color: "transparent"

      WlrLayershell.layer: WlrLayer.Overlay
      WlrLayershell.namespace: "qs-spotlight"
      WlrLayershell.keyboardFocus: root.isVisible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
      
      Rectangle {
        anchors.fill: parent
        color: "#35000000"
        radius: 16
        border.color: "#30FFFFFF"
        border.width: 1

        ColumnLayout {
          anchors.fill: parent
          anchors.margins: 20
          spacing: 16

          TextField {
            id: searchInput
            Layout.fillWidth: true
            font.pixelSize: 26
            placeholderText: "Spotlight Search..."
            color: "white"
            background: Item {}
            
            text: root.currentQuery
            onTextEdited: root.currentQuery = text

            Keys.onPressed: (event) => {
              if (event.key === Qt.Key_Escape) {
                root.isVisible = false;
                event.accepted = true;
              } else if (event.key === Qt.Key_Down) {
                if (resultList.currentIndex < resultsModel.count - 1) {
                  resultList.currentIndex++;
                }
                event.accepted = true;
              } else if (event.key === Qt.Key_Up) {
                if (resultList.currentIndex > 0) {
                  resultList.currentIndex--;
                }
                event.accepted = true;
              } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                if (resultsModel.count > 0 && resultList.currentIndex >= 0) {
                  root.launchResult(resultsModel.get(resultList.currentIndex));
                }
                event.accepted = true;
              }
            }
          }

          Rectangle {
            Layout.fillWidth: true
            height: 1
            color: "#40FFFFFF"
            visible: resultsModel.count > 0
          }

          ListView {
            id: resultList
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: resultsModel
            clip: true
            visible: resultsModel.count > 0
            
            delegate: Rectangle {
              width: resultList.width
              height: 60
              color: resultList.currentIndex === index ? "#40FFFFFF" : "transparent"
              radius: 8
              
              RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 15
                
                IconImage {
                  width: 32
                  height: 32
                  source: Quickshell.iconPath(model.icon, true)
                }
                
                ColumnLayout {
                  Layout.fillWidth: true
                  spacing: 4
                  Text {
                    text: model.name
                    color: "white"
                    font.pixelSize: 18
                    font.bold: true
                  }
                  Text {
                    text: model.type === "app" ? model.exec : model.path
                    color: "#A0A0A0"
                    font.pixelSize: 12
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                  }
                }
              }
              
              MouseArea {
                anchors.fill: parent
                onClicked: {
                  resultList.currentIndex = index;
                  root.launchResult(resultsModel.get(index));
                }
              }
            }
          }
        }
      }
    }
  }
}
