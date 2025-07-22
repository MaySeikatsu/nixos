import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.UPower

Item {
    anchors.verticalCenter: parent.verticalCenter
    anchors.right: parent.right

  Text {
    anchors.verticalCenter: parent.verticalCenter
    anchors.right: parent.right
    anchors.rightMargin: 80
    id: powerstate
    text: Math.round(powerstate.UPower.displayDevice.percentage* 100) + "%"
    color: textColor
  }

Text {
    anchors.verticalCenter: parent.verticalCenter
    anchors.right: parent.right
    anchors.rightMargin: 150
    id: drainTime
    color: textColor

    property int totalSeconds: drainTime.UPower.displayDevice.timeToEmpty
    property int hours: Math.floor(totalSeconds / 3600)
    property int minutes: Math.floor((totalSeconds % 3600) / 60)

    text: hours + "h " + minutes + "m"
  }
}
