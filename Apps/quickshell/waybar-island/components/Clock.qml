import QtQuick
import QtQuick.Layouts

Item {
    id: root

    implicitHeight: 18

    property string timeText: ""
    property string dateText: ""

    Timer {
        interval: 1000
        running: true
        repeat: true

        onTriggered: updateTime()
    }

    function updateTime() {
        const now = new Date()

        root.timeText = Qt.formatTime(now, "HH:mm:ss")
        root.dateText = Qt.formatDate(now, "dddd, dd MMMM yyyy")
    }

    Component.onCompleted: updateTime()

    RowLayout {
        anchors.fill: parent

        spacing: 6

        Text {
            text: root.timeText

            color: Colors.fg

            font.pixelSize: 10
            font.weight: Font.Bold
        }

        Text {
            text: "•"

            color: Colors.fgDim

            font.pixelSize: 9
        }

        Text {
            text: root.dateText

            color: Colors.fgMuted

            font.pixelSize: 10

            elide: Text.ElideRight

            Layout.fillWidth: true
        }
    }
}
