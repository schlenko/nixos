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
    property bool muted: false

    Process {
        id: volumeProcess

        command: [
            "sh",
            "-c",
            "wpctl get-volume @DEFAULT_AUDIO_SINK@"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                const value = text.trim()

                root.muted = value.indexOf("[MUTED]") !== -1

                const match = value.match(/Volume:\s*([0-9.]+)/)

                if (match) {
                    root.level = Math.max(
                        0,
                        Math.min(1, parseFloat(match[1]))
                    )
                }
            }
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true

        onTriggered: volumeProcess.running = true
    }

    function setVolume(value) {
        root.level = value
        root.muted = false

        const process = Qt.createQmlObject(
            'import Quickshell.Io; Process {}',
            root
        )

        process.command = [
            "wpctl",
            "set-volume",
            "@DEFAULT_AUDIO_SINK@",
            Math.round(value * 100) + "%"
        ]

        process.running = true

        process.exited.connect(function() {
            process.destroy()
        })
    }

    function toggleMute() {
        const process = Qt.createQmlObject(
            'import Quickshell.Io; Process {}',
            root
        )

        process.command = [
            "wpctl",
            "set-mute",
            "@DEFAULT_AUDIO_SINK@",
            "toggle"
        ]

        process.running = true

        process.exited.connect(function() {
            volumeProcess.running = true
            process.destroy()
        })
    }

    Component.onCompleted: volumeProcess.running = true

    Rectangle {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom

        width: Math.max(
            48,
            parent.width * root.level
        )

        radius: parent.radius

        color: root.muted
               ? Colors.backgroundHover
               : Colors.accent
    }

    RowLayout {
        anchors.fill: parent

        anchors.leftMargin: 12
        anchors.rightMargin: 12

        spacing: 8

        Text {
            text: root.muted
                  ? "󰝟"
                  : root.level > 0.5
                    ? "󰕾"
                    : root.level > 0
                      ? "󰖀"
                      : "󰕿"

            color: root.muted
                   ? Colors.fgMuted
                   : "#000000"

            font.pixelSize: 18

            MouseArea {
                anchors.fill: parent

                cursorShape: Qt.PointingHandCursor

                onClicked: root.toggleMute()
            }
        }

        Text {
            text: "Volume"

            color: root.level > 0.8 && !root.muted
                   ? "#000000"
                   : Colors.fg

            font.pixelSize: 11
            font.weight: Font.Bold

            Layout.fillWidth: true
        }

        Text {
            text: root.muted
                  ? "Muted"
                  : Math.round(root.level * 100) + "%"

            color: root.muted
                   ? Colors.fgMuted
                   : root.level > 0.8
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
            if (mouse.x < 42) {
                root.toggleMute()
                return
            }

            const value = Math.max(
                0,
                Math.min(1, mouse.x / width)
            )

            root.setVolume(value)
        }

        onPositionChanged: function(mouse) {
            if (!pressed || mouse.x < 42)
                return

            const value = Math.max(
                0,
                Math.min(1, mouse.x / width)
            )

            root.setVolume(value)
        }
    }
}
