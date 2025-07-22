import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
// import ./modules/BottomBar.qml

Scope {
  //Left Bar
  PanelWindow {
    color: barColor // <-- Set your desired color here
    aboveWindows: true
    //Enables Keyboard Shortcuts
    focusable: true 
    //Sets width of the module
    implicitWidth: 10 

    //Anchors the modules to defined sides
    anchors {
      left: true
      right: false
      bottom: true
      top: true
    }
    // Text {
    //   // center the bar in its parent component (the window)
    //   anchors.centerIn: parent
    //   text: "Hello!"
    // }
  }
}

