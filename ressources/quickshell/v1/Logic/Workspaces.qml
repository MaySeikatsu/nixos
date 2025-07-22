import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

        // Showing the current workspace
        Text {
        id: workspaceText
        anchors.verticalCenter: parent.verticalCenter
        // anchors.left: parent.left
        // anchors.leftMargin: 100 // Adjust as needed
        color: textColor
        text: "Workspace: ..."

        Process {
          id: workspaceProc
          // Use 'bash -c' to run piped commands
          command: ["bash", "-c", "hyprctl activeworkspace -j | jq '.id'"]
          running: true

          stdout: StdioCollector {
            onStreamFinished: workspaceText.text = "Workspace: " + this.text.trim()
          }
        }
        Timer {
          interval: 100 // Update every second; adjust for performance
          running: true
          repeat: true
          onTriggered: workspaceProc.running = true
        }
      }
