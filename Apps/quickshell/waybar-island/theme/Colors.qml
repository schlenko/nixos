pragma Singleton

import QtQuick

QtObject {
    readonly property color fg: "#C4A7E7"
    readonly property color fgMuted: Qt.rgba(196, 167, 231, 0.60)
    readonly property color fgDim: Qt.rgba(196, 167, 231, 0.35)

    readonly property color accent: "#C4A7E7"

    readonly property color background: Qt.rgba(0, 0, 0, 0.10)
    readonly property color backgroundHover: Qt.rgba(0, 0, 0, 0.16)
    readonly property color backgroundStrong: Qt.rgba(0, 0, 0, 0.22)

    readonly property color border: "#3f3f42"
    readonly property color borderSoft: Qt.rgba(63, 63, 66, 0.75)

    readonly property color danger: "#ff5555"
    readonly property color success: "#9ccfd8"

    readonly property int outerRadius: 20
    readonly property int cardRadius: 14
    readonly property int buttonRadius: 10
}