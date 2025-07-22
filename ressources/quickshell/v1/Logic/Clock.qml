import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

// ClockView.qml

Text {
    id: clock
    color: textColor
    property int updateInterval: 1000 // ms

    // Optional: allow setting custom margins
    property int rightMargin: 16

    // Anchors are set by the parent, but you can set defaults if you want
    anchors.verticalCenter: parent ? parent.verticalCenter : undefined
    anchors.right: parent ? parent.right : undefined
    anchors.rightMargin: rightMargin

    Process {
        id: dateProc
        command: ["date", "+%H:%M"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: clock.text = this.text.trim()
        }
    }
    Timer {
        interval: clock.updateInterval
        running: true
        repeat: true
        onTriggered: dateProc.running = true
    }
}
