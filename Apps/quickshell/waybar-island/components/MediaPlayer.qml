import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../theme"

Rectangle {
    id: root

    implicitHeight: 92

    radius: Colors.cardRadius

    color: Colors.background
    border.color: Colors.borderSoft
    border.width: 1

    property string title: "Nothing Playing"
    property string artist: ""
    property string status: "Stopped"

    Process {
        id: metadataProcess

        command: [
            "sh",
            "-c",
            "playerctl metadata --format '{{status}}|{{title}}|{{artist}}'"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                const parts = text.trim().split("|")

                if (parts.length >= 3) {
                    root.status = parts[0]
                    root.title = parts[1] || "Unknown title"
                    root.artist = parts.slice(2).join("|") || "Unknown artist"
                } else {
                    root.status = "Stopped"
                    root.title = "Nothing Playing"
                    root.artist = ""
                }
            }
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true

        onTriggered: metadataProcess.running = true
    }

    function command(value) {
        const process = Qt.createQmlObject(
            'import Quickshell.Io; Process {}',
            root
        )

        process.command = ["sh", "-c", value]

        process.running = true

        process.exited.connect(function() {
            process.destroy()
        })
    }

    RowLayout {
        anchors.fill: parent

        anchors.margins: 12

        spacing: 12

        Rectangle {
            width: 48
            height: 48

            radius: 12

            color: root.status === "Playing"
                   ? Colors.accent
                   : Colors.backgroundHover

            Text {
                anchors.centerIn: parent

                text: root.status === "Playing"
                      ? "󰐊"
                      : "󰏤"

                color: root.status === "Playing"
                       ? "#000000"
                       : Colors.fg

                font.pixelSize: 21
            }
        }

        ColumnLayout {
            Layout.fillWidth: true

            spacing: 2

            Text {
                text: root.title

                color: Colors.fg

                font.pixelSize: 12
                font.weight: Font.Bold

                elide: Text.ElideRight

                Layout.fillWidth: true
            }

            Text {
                text: root.artist

                color: Colors.fgMuted

                font.pixelSize: 10

                elide: Text.ElideRight

                Layout.fillWidth: true
            }

            Text {
                text: root.status

                color: Colors.fgDim

                font.pixelSize: 9
            }
        }

        RowLayout {
            spacing: 4

            Rectangle {
                width: 30
                height: 30

                radius: 15

                color: Colors.backgroundHover

                Text {
                    anchors.centerIn: parent

                    text: "󰒮"

                    color: Colors.fg

                    font.pixelSize: 14
                }

                MouseArea {
                    anchors.fill: parent

                    cursorShape: Qt.PointingHandCursor

                    onClicked: root.command("playerctl previous")
                }
            }

            Rectangle {
                width: 30
                height: 30

                radius: 15

                color: Colors.accent

                Text {
                    anchors.centerIn: parent

                    text: root.status === "Playing" ? "󰏤" : "󰐊"

                    color: "#000000"

                    font.pixelSize: 14
                }

                MouseArea {
                    anchors.fill: parent

                    cursorShape: Qt.PointingHandCursor

                    onClicked: root.command("playerctl play-pause")
                }
            }

            Rectangle {
                width: 30
                height: 30

                radius: 15

                color: Colors.backgroundHover

                Text {
                    anchors.centerIn: parent

                    text: "󰒭"

                    color: Colors.fg

                    font.pixelSize: 14
                }

                MouseArea {
                    anchors.fill: parent

                    cursorShape: Qt.PointingHandCursor

                    onClicked: root.command("playerctl next")
                }
            }
        }
    }
}
