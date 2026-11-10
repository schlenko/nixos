pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property int minTemp: 1000
    readonly property int maxTemp: 6500

    property int temperature: Settings.nightLightTemperature
    property bool active: false

    Component.onCompleted: {
        active = true;
    }

    function setTemperature(kelvin) {
        temperature = Math.max(minTemp, Math.min(maxTemp, Math.round(kelvin / 50) * 50));
        active = true;
        debounce.restart();
    }

    function toggle() {
        if (active) {
            active = false;
            run(["hyprctl", "hyprsunset", "identity"]);
        } else {
            active = true;
            run(["hyprctl", "hyprsunset", "temperature", String(temperature)]);
        }
    }

    property var _pending: null

    function run(cmd) {
        _pending = cmd;
        if (!proc.running)
            flush();
    }

    function flush() {
        if (!_pending)
            return;
        proc.command = _pending;
        _pending = null;
        proc.running = true;
    }

    Timer {
        id: debounce
        interval: 80
        onTriggered: root.run(["hyprctl", "hyprsunset", "temperature", String(root.temperature)])
    }

    Process {
        id: proc
        onRunningChanged: if (!running) root.flush()
    }
}