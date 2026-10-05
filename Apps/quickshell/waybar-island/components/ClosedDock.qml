import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../theme"

Item {
    id: root

    signal openRequested()

    property string mediaTitle: ""
    property string mediaArtist: ""
    property bool mediaPlaying: false

    implicitWidth: mediaPlaying ? 300 : 64
    implicitHeight: 42

    Process {
        id: titleProcess

        command: [
            "sh",
            "-c",
            "playerctl metadata --format '{{title}}'"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                root.mediaTitle = text.trim()
            }
        }
    }

    Process {
        id: artistProcess

        command: [
            "sh",
            "-c",
            "playerctl metadata --format '{{artist}}'"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                root.mediaArtist = text.trim()
            }
        }
    }

    Process {
        id: statusProcess

        command: [
            "sh",
            "-c",
            "playerctl status"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                root.mediaPlaying = text.trim() === "Playing"
            }
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true

        onTriggered: {
            titleProcess.running = true
            artistProcess.running = true
            statusProcess.running = true
        }
    }

    Component.onCompleted: {
        titleProcess.running = true
        artistProcess.running = true
        statusProcess.running = true
    }

    Rectangle {
        anchors.fill: parent

        color: Colors.background
        border.color: Colors.border
        border.width: 2
        radius: Colors.outerRadius

        clip: true

        RowLayout {
            anchors.fill: parent

            anchors.leftMargin: 12
            anchors.rightMargin: 12

            spacing: 8

            Text {
                text: "❄"

                color: Colors.fg

                font.pixelSize: 18

                Layout.alignment: Qt.AlignVCenter
            }

            ColumnLayout {
                visible: root.mediaPlaying

                Layout.fillWidth: true

                spacing: 0

                Text {
                    text: root.mediaTitle || "Playing"

                    color: Colors.fg

                    font.pixelSize: 11
                    font.weight: Font.Bold

                    elide: Text.ElideRight

                    Layout.fillWidth: true
                }

                Text {
                    text: root.mediaArtist

                    color: Colors.fgMuted

                    font.pixelSize: 9

                    elide: Text.ElideRight

                    Layout.fillWidth: true
                }
            }
        }

        MouseArea {
            anchors.fill: parent

            cursorShape: Qt.PointingHandCursor

            onClicked: root.openRequested()
        }
    }
}