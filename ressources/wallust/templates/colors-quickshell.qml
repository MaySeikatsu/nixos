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

  property color barColor: "{{color1 | darken(0.6)}}"
  // property color barColor: "{{background}}"
  property color textColor: "{{foreground}}"
  property real barRadius: 20
  property color borderColor: "{{color1 | lighten(0.2)}}"
  property real borderWidth: 2
  property real barModuleSpacing: 50 //Not really doing a thing

    TopBar { }
    // RightBar { }
    // LeftBar { }
    // BottomBar { }
  }
