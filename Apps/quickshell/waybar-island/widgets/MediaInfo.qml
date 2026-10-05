import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../theme"

Item {
    id: root

    property string title: ""
    property string artist: ""
    property bool playing: false

    implicitHeight: 40

    Process {
        id: mediaProcess

        command: [
            "sh",
            "-c",
            "playerctl metadata --format '{{status}}|{{title}}|{{artist}}'"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                const parts = text.trim().split("|")

                if (parts.length >= 3) {
                    root.playing = parts[0] === "Playing"
                    root.title = parts[1]
                    root.artist = parts.slice(2).join("|")
                } else {
                    root.playing = false
                    root.title = ""
                    root.artist = ""
                }
            }
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true

        onTriggered: mediaProcess.running = true
    }

    Component.onCompleted: mediaProcess.running = true

    visible: playing

    RowLayout {
        anchors.fill: parent

        spacing: 8

        Text {
            text: "󰐊"

            color: Colors.fg

            font.pixelSize: 14
        }

        ColumnLayout {
            Layout.fillWidth: true

            spacing: 0

            Text {
                text: root.title

                color: Colors.fg

                font.pixelSize: 10
                font.weight: Font.Bold

                elide: Text.ElideRight

                Layout.fillWidth: true
            }

            Text {
                text: root.artist

                color: Colors.fgMuted

                font.pixelSize: 9

                elide: Text.ElideRight

                Layout.fillWidth: true
            }
        }
    }
}
