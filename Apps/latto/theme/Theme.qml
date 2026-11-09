pragma Singleton

import QtQuick
import "../services"

// Visual constants: font, palette, geometry and motion.
QtObject {
    // The `fontFamily` config key if set, otherwise the system's default Qt
    // font (chosen by qt6ct, KDE or the platform theme).
    readonly property string fontFamily: Settings.fontFamily !== "" ? Settings.fontFamily : Qt.application.font.family

    readonly property int fontCaption: 10
    readonly property int fontSmall: 11
    readonly property int fontBody: 13
    readonly property int fontTitle: 16
    readonly property int fontDisplay: 34
    readonly property int fontWeight: Font.ExtraBold

      // Palette
    readonly property color island: "#000000"
    readonly property color surface: "#151516"
    readonly property color surfaceRaised: "#262628"
    readonly property color border: Qt.rgba(1, 1, 1, 0.07)
    readonly property color text: "#C4A7E7"
    readonly property color textSecondary: "#98989e"
    readonly property color textTertiary: "#5a5a60"
    readonly property color accent: Settings.accentColor
    // Status colors as greys, from lightest (most attention) to darkest
    readonly property color red: "#C4A7E7"
    readonly property color orange: "#C4A7E7"
    readonly property color yellow: "#C4A7E7"
    readonly property color green: "#C4A7E7"
    readonly property color cyan: "#C4A7E7"
    readonly property color blue: "#C4A7E7"
    readonly property color indigo: "#C4A7E7"
    // Agent identity colors; user overrides also support future adapters.
    readonly property color claude: agentColor("claude")
    function agentColor(agent) {
        const name = (agent || "").toLowerCase().trim();
        const key = name === "claude code" ? "claude" : name;
        const overrides = Settings.agentColors || {};
        if (overrides[key]) return overrides[key];
        if (key === "claude") return "#C4A7E7";
        if (key === "kiro") return "#C4A7E7";
        if (key === "codex") return "#C4A7E7";
        return accent;
    }

    // Island geometry
    readonly property int topMargin: 8
    readonly property int compactHeight: 36
    readonly property int idleWidth: 210
    readonly property int activityWidth: 340
    readonly property int expandedWidth: 600
    readonly property int expandedHeight: 276
    readonly property int expandedRadius: 0
    readonly property int notificationWidth: 420
    readonly property int notificationHeight: 76
    readonly property int notificationRadius: 28
    // What the island shrinks to before disappearing in fullscreen.
    readonly property int dotSize: 12
    readonly property int padding: 18
    readonly property int cardRadius: 0

    // Motion. Curves are cubic beziers in the [x1, y1, x2, y2, 1, 1] form that
    // Easing.BezierSpline expects.
    readonly property var springCurve: [0.34, 1.36, 0.64, 1, 1, 1]    // overshoots, then settles
    readonly property var settleCurve: [0.3, 1.12, 0.5, 1, 1, 1]      // gentler overshoot
    readonly property var smoothCurve: [0.32, 0.72, 0, 1, 1, 1]       // quick start, soft landing
    readonly property var exitCurve: [0.4, 0, 1, 1, 1, 1]             // accelerates away

    readonly property int expandDuration: 560
    readonly property int collapseDuration: 460
    readonly property int morphDuration: 480
    readonly property int fadeDuration: 200

    // Blur transitions: hidden content sits blurred and sharpens as it
    // appears. Swaps between views (blur-replace) use a lighter blur.
    readonly property real hiddenBlur: 1.0
    readonly property real swapBlur: 0.55
    readonly property int swapDuration: 340

    // Hover debounce: brushing past does not open, leaving always closes.
    readonly property int hoverOpenDelay: 70
    readonly property int hoverCloseDelay: 240
}
