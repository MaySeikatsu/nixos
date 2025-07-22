import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
// import ./modules/topbar.qml

ShellRoot {
  // id: topbar
  //Top Bar
  PanelWindow {
    aboveWindows: true
    //Enables Keyboard Shortcuts
    focusable: true 
    //Sets heigt of the module
    implicitHeight: 30
    // implicitWidth: 10 

    //Anchors the modules to defined sides
    anchors {
      left: true
      right: true
      bottom: false
      top: true
    }
    //Defines margins from corners 
    // margins {
    //   left: 10
    //   right: 10
    //   bottom: 10
    //   top: 10
    // }
    // Text {
    //   // center the bar in its parent component (the window)
    //   anchors.centerIn: parent
    //   text: "Hello!"
    // }
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
      //Needed to update the time, calls id dateProc and thus executes to reload the Process defined with that ID
      Timer {
        interval: 1000 // = 1 second
        running: true //starts the timer immediately once quickshell starts
        repeat: true // run the timer again when it ends

        // when the timer is triggered, set the running property of the
        // process to true, which reruns it if stopped.
        onTriggered: dateProc.running = true

      }
    }
  }
  //Bottom Bar
  id: bottombar
  PanelWindow {
    aboveWindows: true
    //Enables Keyboard Shortcuts
    focusable: true 
    //Sets heigt of the module
    implicitHeight: 10 
    // implicitWidth: 10 

    //Anchors the modules to defined sides
    anchors {
      left: true
      right: true
      bottom: true
      top: false
    }

    //Defines margins from corners 
    // margins {
    //   left: 10
    //   right: 10
    //   bottom: 10
    //   top: 10
    // }

    Text {
      // center the bar in its parent component (the window)
      anchors.centerIn: parent
      text: "Hello!"
    }
  }
  //Left Bar
  PanelWindow {
    aboveWindows: true
    //Enables Keyboard Shortcuts
    focusable: true 
    //Sets heigt of the module
    // implicitHeight: 10 
    implicitWidth: 10 

    //Anchors the modules to defined sides
    anchors {
      left: true
      right: false
      bottom: true
      top: true
    }
    //Defines margins from corners 
    // margins {
    //   left: 10
    //   right: 10
    //   bottom: 10
    //   top: 10
    // }
    Text {
      // center the bar in its parent component (the window)
      anchors.centerIn: parent
      text: "Hello!"
    }
  }
  //Left Bar
  PanelWindow {
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
    //Defines margins from corners 
    // margins {
    //   left: 10
    //   right: 10
    //   bottom: 10
    //   top: 10
    // }
    Text {
      // center the bar in its parent component (the window)
      anchors.centerIn: parent
      text: "Hello!"
    }
  }
  // PanelWindow {
  //   aboveWindows: true
  //
  //   anchors {
  //     left: true
  //     right: true
  //     bottom: false
  //     top: true
  //   }
  //   Text {
  //     anchors.centerIn: parent
  //     text: "Hello!"
  //   }
  // }

  // FloatingWindow {
  //     width: 200
  //     height: 100
  //     color: "red"
  // }
}

