import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../theme"

Item {
    id: root

    required property var screen

    property bool expanded: false

    implicitWidth: expanded ? 430 : closedDock.implicitWidth
    implicitHeight: expanded ? openDock.implicitHeight : closedDock.implicitHeight

    Behavior on implicitWidth {
        NumberAnimation {
            duration: 220
            easing.type: Easing.OutCubic
        }
    }

    Behavior on implicitHeight {
        NumberAnimation {
            duration: 220
            easing.type: Easing.OutCubic
        }
    }

    ClosedDock {
        id: closedDock

        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter

        visible: !root.expanded

        onOpenRequested: root.expanded = true
    }

    OpenDock {
        id: openDock

        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter

        visible: root.expanded

        onCloseRequested: root.expanded = false
    }
}