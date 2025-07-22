import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland

Item {
  Row {
      spacing: 2
  anchors.verticalCenter: parent.verticalCenter
      // Show all workspaces
      Repeater {
          model: Hyprland.workspaces
          delegate: Rectangle {
              width: 20
              height: 20
              // radius: barRadius
              color: workspace.active ? borderColor : "#333"
              border.color: workspace.active ? "#333" : borderColor
              border.width: workspace.active ? 2 : 1

              // This injects the current workspace into the delegate
              property var workspace: modelData

              // Show workspace number or name
              Text {
                  anchors.centerIn: parent
                  color: textColor
                  text: workspace.id
              }

              // Switch to workspace on click
              MouseArea {
                  anchors.fill: parent
                  onClicked: workspace.activate()
                  cursorShape: Qt.PointingHandCursor
              }
          }
      }
  }
}
