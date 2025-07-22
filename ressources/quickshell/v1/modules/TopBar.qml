import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "../Logic"

Scope {
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

        color: "transparent" // <-- Set your desired color here
        // color: barColor // <-- Set your desired color here
        //
        // Add this Rectangle as the first child for background color
        Rectangle {
          anchors.fill: parent
          color: barColor // <-- Set your desired color here
          radius: barRadius
          border.color: borderColor
          border.width: borderWidth
          antialiasing: true

          Item {
            id: leftZone
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            width: Math.max(leftRow.implicitWidth, 100) // (optional, min width)
            height: parent.height

            RowLayout {
              id: leftRow
              anchors.verticalCenter: parent.verticalCenter
              spacing: barModuleSpacing

              Menu { }
              WorkspaceSelector {}
            }
          }

          Item {
            id: centerZone
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            width: Math.max(leftRow.implicitWidth, 100) // (optional, min width)
            height: parent.height

            RowLayout {
              id: centerRow
              anchors.verticalCenter: parent.verticalCenter
              spacing: barModuleSpacing

              Workspaces {}
              Audio{}
              // Volume {}
            }
          }

          Item {
            id: rightZone
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            width: Math.max(leftRow.implicitWidth, 260) // (optional, min width)
            height: parent.height

            RowLayout {
              id: rightRow
              anchors.verticalCenter: parent.verticalCenter
              spacing: barModuleSpacing

              Wifi { }
              Clock { 
                  // anchors.verticalCenter: parent.verticalCenter
                  // anchors.right: parent.right
                  // anchors.rightMargin: 16
              }
              Battery { }
            }
          }

        }


      }
    }
  }
}

