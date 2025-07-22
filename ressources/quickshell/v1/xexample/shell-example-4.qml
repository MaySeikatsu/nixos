import Quickshell
import Quickshell.Io
import QtQuick

Variants {
  model: Quickshell.screens;

  delegate: Component {
    PanelWindow {
      // the screen from the screens list will be injected into this
      // property
      property var modelData

      // we can then set the window's screen to the injected property
      screen: modelData

      anchors {
        top: true
        left: true
        right: true
      }

      implicitHeight: 30

      Text {
        id: clock
        anchors.centerIn: parent

        Process {
          id: dateProc
          command: ["date"]
          running: true

          stdout: StdioCollector {
            onStreamFinished: clock.text = this.text
          }
        }

        Timer {
          interval: 1000
          running: true
          repeat: true
          onTriggered: dateProc.running = true
        }
      }
    }
  }
}
