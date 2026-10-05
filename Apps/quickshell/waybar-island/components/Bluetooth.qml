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

    Process {
        id: statusProcess

        command: [
            "sh",
            "-c",
            "bluetoothctl show | grep -q 'Powered: yes'"
        ]

        onExited: function(exitCode) {
            root.enabled = exitCode === 0
        }
    }

    Timer {
        interval: 3000
        running: true
        repeat: true

        onTriggered: statusProcess.running = true
    }

    function toggle() {
        const process = Qt.createQmlObject(
            'import Quickshell.Io; Process {}',
            root
        )

        process.command = [
            "bluetoothctl",
            "power",
            root.enabled ? "off" : "on"
        ]

        process.running = true

        process.exited.connect(function() {
            statusProcess.running = true
            process.destroy()
        })
    }

    Component.onCompleted: statusProcess.running = true

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

                text: root.enabled ? "󰂯" : "󰂲"

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
                text: "Bluetooth"

                color: Colors.fg

                font.pixelSize: 11
                font.weight: Font.Bold
            }

            Text {
                text: root.enabled ? "Enabled" : "Disabled"

                color: Colors.fgMuted

                font.pixelSize: 9
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
