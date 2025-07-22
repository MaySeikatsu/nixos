import QtQuick
import Quickshell
import "modules"
// import "Logic"
import "Theme"

//Currently all changes need to be added to wallust too (or just created in the template file)

ShellRoot {

  // property real barRadius: 20
  // property real borderWidth: 2
  // property real barModuleSpacing: 50 //Not really doing a thing

  property color barColor: "#201738"
  // property color barColor: "#1D1625"
  property color textColor: "#FDF9FD"
  property real barRadius: 20
  property color borderColor: "#7261A2"
  property real borderWidth: 2
  property real barModuleSpacing: 50 //Not really doing a thing

    TopBar { }
    // RightBar { }
    // LeftBar { }
    // BottomBar { }
  }
