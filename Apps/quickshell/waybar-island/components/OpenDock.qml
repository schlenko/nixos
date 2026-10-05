import QtQuick
import QtQuick.Layouts
import "../theme"

Item {
    id: root

    signal closeRequested()

    implicitWidth: 430
    implicitHeight: content.implicitHeight

    Rectangle {
        anchors.fill: parent

        color: Colors.background
        border.color: Colors.border
        border.width: 2
        radius: Colors.outerRadius

        clip: true

        ColumnLayout {
            id: content

            anchors.fill: parent
            anchors.margins: 14

            spacing: 10

            RowLayout {
                Layout.fillWidth: true

                spacing: 8

                ColumnLayout {
                    Layout.fillWidth: true

                    spacing: 1

                    Text {
                        text: "Control Center"

                        color: Colors.fg

                        font.pixelSize: 15
                        font.weight: Font.Bold
                    }

                    Clock {
                        Layout.fillWidth: true
                    }
                }

                Rectangle {
                    width: 34
                    height: 34

                    radius: 17

                    color: Colors.backgroundHover
                    border.color: Colors.borderSoft
                    border.width: 1

                    Text {
                        anchors.centerIn: parent

                        text: "󰅖"

                        color: Colors.fg

                        font.pixelSize: 15
                    }

                    MouseArea {
                        anchors.fill: parent

                        cursorShape: Qt.PointingHandCursor

                        onClicked: root.closeRequested()
                    }
                }
            }

            MediaPlayer {
                Layout.fillWidth: true
            }

            RowLayout {
                Layout.fillWidth: true

                spacing: 8

                Wifi {
                    Layout.fillWidth: true
                }

                Bluetooth {
                    Layout.fillWidth: true
                }
            }

            Volume {
                Layout.fillWidth: true
            }

            Brightness {
                Layout.fillWidth: true
            }

            PowerButtons {
                Layout.fillWidth: true
            }
        }
    }
}