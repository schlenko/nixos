import QtQuick
import Quickshell
import Quickshell.Wayland

ShellRoot {
    id: root

    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData

            screen: modelData

            color: "transparent"

            WlrLayershell.layer: WlrLayer.Top
            WlrLayershell.namespace: "quickshell-control"

            anchors {
                top: true
                left: true
                right: true
            }

            implicitHeight: 900

            Dock {
                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                screen: modelData
            }
        }
    }
}