import QtQuick
import Quickshell
import "../../services"
import "../../theme"
import ".."

// Notification history, newest first, with the Do Not Disturb switch.
Item {
    id: root

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    Label {
        anchors.left: parent.left
        anchors.leftMargin: 4
        anchors.verticalCenter: header.verticalCenter
        text: Notifications.count === 0 ? "No notifications"
            : Notifications.count + (Notifications.count === 1 ? " notification" : " notifications")
        color: Theme.textTertiary
        font.pixelSize: Theme.fontSmall
        font.weight: Font.Medium
    }

    Row {
        id: header
        anchors.right: parent.right
        anchors.top: parent.top
        spacing: 6

        IslandButton {
            visible: Notifications.count > 0
            text: "Clear all"
            fontSize: Theme.fontSmall
            subtle: true
            onClicked: Notifications.clearAll()
        }
        IslandButton {
            icon: "moon"
            iconSize: 13
            text: Notifications.doNotDisturb ? "Do Not Disturb on" : "Do Not Disturb"
            fontSize: Theme.fontSmall
            subtle: true
            color: Notifications.doNotDisturb ? Theme.indigo : Theme.textSecondary
            onClicked: Notifications.toggleDoNotDisturb()
        }
    }

    Column {
        anchors.centerIn: list
        spacing: 8
        visible: Notifications.count === 0

        Icon {
            anchors.horizontalCenter: parent.horizontalCenter
            name: Notifications.doNotDisturb ? "moon" : "bell"
            size: 28
            color: Notifications.doNotDisturb ? Theme.indigo : Theme.textTertiary
        }
        Label {
            anchors.horizontalCenter: parent.horizontalCenter
                text: !Settings.notificationsEnabled ? "Waiting for mako notifications"
                : Notifications.doNotDisturb ? "Do Not Disturb is on" : "You're all caught up"
            color: Theme.textSecondary
        }
    }


    ListView {
        id: list
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: header.bottom
        anchors.bottom: parent.bottom
        anchors.topMargin: 12
        spacing: 8
        clip: true
            model: Notifications.history.concat(Notifications.mirrored)
        boundsBehavior: Flickable.StopAtBounds

        delegate: Item {
            id: row
            required property var modelData

            width: ListView.view.width
            height: loader.item ? loader.item.height : 0

            Loader {
                id: loader
                width: parent.width
                sourceComponent: row.modelData.mirrored === true ? mirroredCard : realCard
            }

            Component {
                id: realCard
                NotificationCard {
                    notification: row.modelData
                    now: clock.date.getTime()
                }
            }

            Component {
                id: mirroredCard
                Rectangle {
                    radius: 12
                    color: Theme.surface
                    implicitHeight: content.implicitHeight + 20

                    Column {
                        id: content
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.margins: 10
                        anchors.rightMargin: 34
                        spacing: 2

                        Label {
                            width: content.width
                            text: row.modelData.appName + "  ·  "
                                + Notifications.ageSince(row.modelData.at, clock.date.getTime())
                            color: Theme.textTertiary
                            font.pixelSize: Theme.fontSmall
                            elide: Text.ElideRight
                        }
                        Label {
                            width: content.width
                            text: row.modelData.summary
                            font.weight: Font.DemiBold
                            elide: Text.ElideRight
                        }
                        Label {
                            width: content.width
                            visible: row.modelData.body !== ""
                            text: row.modelData.body
                            color: Theme.textSecondary
                            font.pixelSize: Theme.fontBody - 1
                            wrapMode: Text.Wrap
                            maximumLineCount: 3
                            elide: Text.ElideRight
                        }
                    }

                    IslandButton {
                        anchors.top: parent.top
                        anchors.right: parent.right
                        anchors.margins: 4
                        icon: "close"
                        iconSize: 13
                        color: Theme.textSecondary
                        onClicked: Notifications.dismissMirrored(row.modelData.id)
                    }
                }
            }
        }
    }
}
