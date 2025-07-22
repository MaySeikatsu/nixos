import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

ShellRoot {
	Variants {
		// Create the panel once on each monitor.
		model: Quickshell.screens

		PanelWindow {
			id: w

        // Rectangle {
        //   width: 400
        //   height: 100
        //   color: "#222222"
        //   anchors.centerIn: parent
        //   // anchors.top: parent.top
        //   // anchors.horizontalCenter: parent.horizontalCenter
        //   Column {
        //     anchors.centerIn: parent
        //     spacing: 10
        //     Text {
        //       // text: Quickshell.hostname
        //       text: "UwU"
        //       color: "white"
        //     }
        //   }
        // }

			property var modelData
			screen: modelData

			anchors {
				right: true
				// left: true
				bottom: true
			}

			margins {
				right: 50
				// left: 50
				bottom: 50
			}

			implicitWidth: content.width
			implicitHeight: content.height

			color: "transparent"

			// Give the window an empty click mask so all clicks pass through it.
			mask: Region {}

			// Use the wlroots specific layer property to ensure it displays over
			// fullscreen windows.
			WlrLayershell.layer: WlrLayer.Overlay

			ColumnLayout {
				id: content

				Text {
					text: "Activate Linux"
					color: "#50ffffff"
					font.pointSize: 22
				}

				Text {
					text: "Go to Settings to activate Linux"
					color: "#50ffffff"
					font.pointSize: 14
				}

			}
		}
	}
}
