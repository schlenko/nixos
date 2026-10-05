import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../theme"

Rectangle {
    id: root

    implicitHeight: 76

    radius: Colors.cardRadius

    color: Colors.background
    border.color: Colors.borderSoft
    border.width: 1

    property bool enabled: false
    property string ssid: "Disconnected"

    Process {
        id: statusProcess

        command: [
            "sh",
            "-c",
            "nmcli radio wifi"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                root.enabled = text.trim() === "enabled"
            }
        }
    }

    Process {
        id: ssidProcess

        command: [
            "sh",
            "-c",
            "nmcli -t -f ACTIVE,SSID dev wifi | awk -F: '$1==\"yes\" {print $2; exit}'"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                const value = text.trim()

                root.ssid = value || "Disconnected"
            }
        }
    }

    Timer {
        interval: 3000
        running: true
        repeat: true

        onTriggered: {
            statusProcess.running = true
            ssidProcess.running = true
        }
    }

    function toggle() {
        const process = Qt.createQmlObject(
            'import Quickshell.Io; Process {}',
            root
        )

        process.command = [
            "sh",
            "-c",
            root.enabled
                ? "nmcli radio wifi off"
                : "nmcli radio wifi on"
        ]

        process.running = true

        process.exited.connect(function() {
            statusProcess.running = true
            ssidProcess.running = true
            process.destroy()
        })
    }

    Component.onCompleted: {
        statusProcess.running = true
        ssidProcess.running = true
    }

    RowLayout {
        anchors.fill: parent

        anchors.margins: 12

        spacing: 10

        Rectangle {
            width: 36
            height: 36

            radius: 18

            color: root.enabled
                   ? Colors.accent
                   : Colors.backgroundHover

            Text {
                anchors.centerIn: parent

                text: root.enabled ? "󰖩" : "󰖪"

                color: root.enabled
                       ? "#000000"
                       : Colors.fgMuted

                font.pixelSize: 17
            }
        }

        ColumnLayout {
            Layout.fillWidth: true

            spacing: 2

            Text {
                text: "Wi-Fi"

                color: Colors.fg

                font.pixelSize: 11
                font.weight: Font.Bold
            }

            Text {
                text: root.enabled ? root.ssid : "Disabled"

                color: Colors.fgMuted

                font.pixelSize: 9

                elide: Text.ElideRight

                Layout.fillWidth: true
            }
        }

        Rectangle {
            width: 44
            height: 28

            radius: 14

            color: root.enabled
                   ? Colors.accent
                   : Colors.backgroundHover

            Text {
                anchors.centerIn: parent

                text: root.enabled ? "ON" : "OFF"

                color: root.enabled
                       ? "#000000"
                       : Colors.fg

                font.pixelSize: 9
                font.weight: Font.Bold
            }

            MouseArea {
                anchors.fill: parent

                cursorShape: Qt.PointingHandCursor

                onClicked: root.toggle()
            }
        }
    }
}
