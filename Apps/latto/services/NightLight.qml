pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property int minTemp: 1000
    readonly property int maxTemp: 6500

    // Live value the UI binds to. Starts from the config default.
    property int temperature: Settings.nightLightTemperature
    property bool active: false

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
        // If a newer value arrived while this one was running, send it now.
        onRunningChanged: if (!running) root.flush()
    }
}