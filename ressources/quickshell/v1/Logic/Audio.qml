// AudioDeviceIndicator.qml
import QtQuick
import QtMultimedia
import Quickshell.Services.Pipewire

Item {
    id: root
    width: 200
    height: 48

    property string deviceName: (audioOutput.device ? audioOutput.device.description : "Default")
    property real volumePercent: Math.round(audioOutput.volume*100)

    AudioOutput {
        id: audioOutput
        // Optionally: set an explicit deviceId or leave default
        // deviceId: ...
    }

    Row {
        spacing: 12
        anchors.fill: parent
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter

        Text {
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
            text: "Speaker: " + root.deviceName
            color: "white"
        }

        Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
            id: volumeBar
            width: 80
            height: 16
            color: "#333"
            radius: 8

            Rectangle {
                width: parent.width * audioOutput.volume
                height: parent.height
                color: "#6cf"
                radius: parent.radius
            }
        }

        Text {
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
            text: root.volumePercent + "%"
            color: "white"
        }
    }
}
