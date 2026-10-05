import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../theme"

Rectangle {
    id: root

    implicitHeight: 48

    radius: 24

    color: Colors.background

    border.color: Colors.borderSoft
    border.width: 1

    property real level: 0.5

    Process {
        id: brightnessProcess

        command: [
            "sh",
            "-c",
            "brightnessctl -m | awk -F, '{print $4}' | tr -d '%'"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                const value = parseFloat(text.trim())

                if (!isNaN(value)) {
                    root.level = Math.max(
                        0.05,
                        Math.min(1, value / 100)
                    )
                }
            }
        }
    }

    Timer {
        interval: 1500
        running: true
        repeat: true

        onTriggered: brightnessProcess.running = true
    }

    function setBrightness(value) {
        root.level = value

        const process = Qt.createQmlObject(
            'import Quickshell.Io; Process {}',
            root
        )

        process.command = [
            "brightnessctl",
            "set",
            Math.round(value * 100) + "%"
        ]

        process.running = true

        process.exited.connect(function() {
            process.destroy()
        })
    }

    Component.onCompleted: brightnessProcess.running = true

    Rectangle {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom

        width: Math.max(
            48,
            parent.width * root.level
        )

        radius: parent.radius

        color: Colors.accent
    }

    RowLayout {
        anchors.fill: parent

        anchors.leftMargin: 12
        anchors.rightMargin: 12

        spacing: 8

        Text {
            text: root.level > 0.6
                  ? "󰃠"
                  : root.level > 0.25
                    ? "󰃟"
                    : "󰃞"

            color: "#000000"

            font.pixelSize: 18
        }

        Text {
            text: "Brightness"

            color: root.level > 0.8
                   ? "#000000"
                   : Colors.fg

            font.pixelSize: 11
            font.weight: Font.Bold

            Layout.fillWidth: true
        }

        Text {
            text: Math.round(root.level * 100) + "%"

            color: root.level > 0.8
                   ? "#000000"
                   : Colors.fg

            font.pixelSize: 11
            font.weight: Font.Bold
        }
    }

    MouseArea {
        anchors.fill: parent

        cursorShape: Qt.PointingHandCursor

        onClicked: function(mouse) {
            const value = Math.max(
                0.05,
                Math.min(1, mouse.x / width)
            )

            root.setBrightness(value)
        }

        onPositionChanged: function(mouse) {
            if (!pressed)
                return

            const value = Math.max(
                0.05,
                Math.min(1, mouse.x / width)
            )

            root.setBrightness(value)
        }
    }
}
