import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../theme"

RowLayout {
    id: root

    spacing: 8

    function run(command) {
        const process = Qt.createQmlObject(
            'import Quickshell.Io; Process {}',
            root
        )

        process.command = [
            "systemctl",
            command
        ]

        process.running = true

        process.exited.connect(function() {
            process.destroy()
        })
    }

    Rectangle {
        Layout.fillWidth: true

        height: 42

        radius: 21

        color: Colors.background

        border.color: Colors.border
        border.width: 1

        RowLayout {
            anchors.centerIn: parent

            spacing: 7

            Text {
                text: "󰐥"

                color: Colors.danger

                font.pixelSize: 16
            }

            Text {
                text: "Shutdown"

                color: Colors.fg

                font.pixelSize: 10
                font.weight: Font.Bold
            }
        }

        MouseArea {
            anchors.fill: parent

            cursorShape: Qt.PointingHandCursor

            onClicked: root.run("poweroff")
        }
    }

    Rectangle {
        Layout.fillWidth: true

        height: 42

        radius: 21

        color: Colors.background

        border.color: Colors.border
        border.width: 1

        RowLayout {
            anchors.centerIn: parent

            spacing: 7

            Text {
                text: "󰜉"

                color: Colors.fg

                font.pixelSize: 16
            }

            Text {
                text: "Restart"

                color: Colors.fg

                font.pixelSize: 10
                font.weight: Font.Bold
            }
        }

        MouseArea {
            anchors.fill: parent

            cursorShape: Qt.PointingHandCursor

            onClicked: root.run("reboot")
        }
    }
}
