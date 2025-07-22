import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

// --- WiFi status start ---
Text {
id: wifiStatus
anchors.verticalCenter: parent.verticalCenter
anchors.right: parent.right
anchors.rightMargin: 220
color: textColor
text: wifiStatus.wifiText

property string wifiText: "WiFi: ..."

// Check WiFi status (enabled/disabled)
Process {
id: wifiEnabledProc
command: ["bash", "-c", "nmcli -t -f WIFI general"]
running: true
stdout: StdioCollector {
onStreamFinished: {
let status = this.text.trim()
if (status === "enabled") {
  wifiStatus.wifiText = "WiFi: Searching..."
  wifiSSIDProc.running = true
    } else if (status === "disabled") {
      wifiStatus.wifiText = "WiFi: Disabled"
    } else {
      wifiStatus.wifiText = "WiFi: Unknown"
    }
  }
}
}
// Check current SSID if WiFi is enabled
Process {
id: wifiSSIDProc
command: ["bash", "-c", "nmcli -t -f ACTIVE,SSID dev wifi | grep '^yes' | cut -d: -f2-"]
running: false
stdout: StdioCollector {
    onStreamFinished: {
      let ssid = this.text.trim()
      if (ssid.length > 0) {
        wifiStatus.wifiText = "WiFi: " + ssid
      } else {
          wifiStatus.wifiText = "WiFi: Not connected"
        }
      }
    }
  }
  Timer {
    interval: 5000  // update every 5 seconds, adjust as needed
    running: true
    repeat: true
    onTriggered: wifiEnabledProc.running = true
  }
}
// --- WiFi status end ---
