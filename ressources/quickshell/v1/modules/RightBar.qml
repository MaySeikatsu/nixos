import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

Scope {
  //Right Bar
  PanelWindow {
    color: barColor // <-- Set your desired color here
    aboveWindows: true
    focusable: true 
    // implicitHeight: 10 
    implicitWidth: 10 

    //Anchors the modules to defined sides
    anchors {
      left: false
      right: true
      bottom: true
      top: true
    }
    Text {
      // center the bar in its parent component (the window)
      anchors.centerIn: parent
      text: "Hello!"
    }
  }
}

