import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

Scope {
    //Bottom Bar
  id: bottombar
  PanelWindow {
    color: barColor // <-- Set your desired color here
    aboveWindows: true
    //Enables Keyboard Shortcuts
    focusable: true 
    //Sets heigt of the module
    implicitHeight: 10 

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
    
    Item {
      id: leftZone
      anchors.left: parent.left
      anchors.verticalCenter: parent.verticalCenter
      width: Math.max(leftRow.implicitWidth, 100) // (optional, min width)
      height: parent.height

      RowLayout {
        id: leftRow
        anchors.verticalCenter: parent.verticalCenter
        spacing: 20

        Text {
          // center the bar in its parent component (the window)
          // anchors.centerIn: parent
          // anchors.horizontalCenter: parent.horizontalCenter
          anchors.verticalCenter: parent.verticalCenter
          text: "Hello1"
          color: textColor
        }
        Text {
          // center the bar in its parent component (the window)
          // anchors.centerIn: parent
          // anchors.horizontalCenter: parent.horizontalCenter
          anchors.verticalCenter: parent.verticalCenter
          text: "Hello1"
          color: textColor
        }
        Text {
          // center the bar in its parent component (the window)
          // anchors.centerIn: parent
          // anchors.horizontalCenter: parent.horizontalCenter
          anchors.verticalCenter: parent.verticalCenter
          text: "Hello1"
          color: textColor
        }

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
        spacing: 20

        Text {
          // center the bar in its parent component (the window)
          // anchors.centerIn: parent
          // anchors.horizontalCenter: parent.horizontalCenter
          anchors.verticalCenter: parent.verticalCenter
          text: "Hello1"
          color: textColor
        }
        Text {
          // center the bar in its parent component (the window)
          // anchors.centerIn: parent
          // anchors.horizontalCenter: parent.horizontalCenter
          anchors.verticalCenter: parent.verticalCenter
          text: "Hello1"
          color: textColor
        }
        Text {
          // center the bar in its parent component (the window)
          // anchors.centerIn: parent
          // anchors.horizontalCenter: parent.horizontalCenter
          anchors.verticalCenter: parent.verticalCenter
          text: "Hello1"
          color: textColor
        }
      }
    }
    Item {
      id: rightZone 
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      width: Math.max(leftRow.implicitWidth, 100) // (optional, min width)
      height: parent.height

      RowLayout {
        id: rightRow
        anchors.verticalCenter: parent.verticalCenter
        spacing: 20

        Text {
          // center the bar in its parent component (the window)
          // anchors.centerIn: parent
          // anchors.horizontalCenter: parent.horizontalCenter
          anchors.verticalCenter: parent.verticalCenter
          text: "Hello1"
          color: textColor
        }
        Text {
          // center the bar in its parent component (the window)
          // anchors.centerIn: parent
          // anchors.horizontalCenter: parent.horizontalCenter
          anchors.verticalCenter: parent.verticalCenter
          text: "Hello1"
          color: "white"
        }
        Text {
          // center the bar in its parent component (the window)
          // anchors.centerIn: parent
          // anchors.horizontalCenter: parent.horizontalCenter
          anchors.verticalCenter: parent.verticalCenter
          text: "Hello1"
          color: "white"
        }
      }
    }


    // RowLayout {
    //   anchors.fill: parent
    //   spacing: 30
    //
    //   Text {
    //     // center the bar in its parent component (the window)
    //     // anchors.centerIn: parent
    //     // anchors.horizontalCenter: parent.horizontalCenter
    //     anchors.verticalCenter: parent.verticalCenter
    //     text: "Hello1"
    //     color: "white"
    //   }
    //
    //   Text {
    //     // center the bar in its parent component (the window)
    //     // anchors.centerIn: parent
    //     anchors.verticalCenter: parent.verticalCenter
    //     text: "Hello2"
    //     color: "white"
    //   }
    //   Text {
    //     // center the bar in its parent component (the window)
    //     // anchors.centerIn: parent
    //     anchors.verticalCenter: parent.verticalCenter
    //     text: "Hello3"
    //     color: "white"
    //   }
    //   Text {
    //     // center the bar in its parent component (the window)
    //     // anchors.centerIn: parent
    //     anchors.verticalCenter: parent.verticalCenter
    //     text: "Hello4"
    //     color: "white"
    //   }
    //   Text {
    //     // center the bar in its parent component (the window)
    //     // anchors.centerIn: parent
    //     anchors.verticalCenter: parent.verticalCenter
    //     text: "Hello5"
    //     color: "white"
    //   }
    //   Text {
    //     // center the bar in its parent component (the window)
    //     // anchors.centerIn: parent
    //     anchors.verticalCenter: parent.verticalCenter
    //     text: "Hello6"
    //     color: "white"
    //   }
    // }
  }
}
