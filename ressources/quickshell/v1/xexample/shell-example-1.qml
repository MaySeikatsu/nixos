import Quickshell //Requfor Quickshell-specific types and the Quickshell singleton
import QtQuick //Required for basic qml types like Item, Rectangle, Text
import QtQuick.Controls //Required for UI Controls like Button, Slider, TexField
import Quickshell.Wayland
import "./modules" //way to import folders or other files
import "root:assets" //same as above but starting directly from root

// Use ShellRoot for entrypoint in shell.qml and Scope for subcomponents and panels - is needed as entrypoint on each file
ShellRoot {
  Rectangle {
    width: 400
    height: 100
    color: "#222222"
    // anchors.centerIn: parent
    anchors.top: parent.top
    anchors.horizontalCenter: parent.horizontalCenter
    Column {
      anchors.centerIn: parent
      spacing: 10
      Text {
        // text: Quickshell.hostname
        text: "UwU"
        color: "white"
      }

      // Text {
      //   text: Quickshell.hostname !== undefined ? Quickshell.hostname : "Hostname not available"
      // }
    // Text {
    //     text: Quickshell.hostname + " - " + AppSettings.username
    // }
    //
      Button {
          text: "Reload Shell"
          onClicked: Quickshell.reload()
      }
    }
  }
}

