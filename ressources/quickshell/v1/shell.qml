import QtQuick
import Quickshell
import "modules"
// import "Logic"
import "Theme"


ShellRoot {

  // property real barRadius: 20
  // property real borderWidth: 2
  // property real barModuleSpacing: 50 //Not really doing a thing

  property color barColor: "black"
  property color textColor: "white"
  property real barRadius: 20
  property color borderColor: "gray"
  property real borderWidth: 2
  property real barModuleSpacing: 50 //Not really doing a thing

    TopBar { }
    // RightBar { }
    // LeftBar { }
    // BottomBar { }
  }
