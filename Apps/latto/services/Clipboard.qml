pragma Singleton

import QtQuick
import Quickshell.Io

// Clipboard history backed by cliphist. wl-paste feeds every copy into it
// while clipboardEnabled is set.
QtObject {
    id: root

    readonly property int maxItems: 40

    // [{ id, text }], newest first
    property var items: []

    // Full text of the entry being edited (the list only has one-line previews).
    property string editText: ""
    property string loadingId: ""
    signal editLoaded(string id)

    function isId(id) {
        return /^\d+$/.test(id);
    }

    function refresh() {
        if (Settings.clipboardEnabled)
            listing.running = true;
    }

    function copy(id) {
        if (isId(id))
            run("cliphist decode " + id + " | wl-copy");
    }

    function remove(id) {
        if (isId(id))
            run("cliphist list | awk -F '\\t' '$1 == \"" + id + "\"' | cliphist delete");
    }

    function clear() {
        run("cliphist wipe");
    }

    // Load the full text of an entry for editing; emits editLoaded when ready.
    function load(id) {
        if (!isId(id))
            return;
        loadingId = id;
        loader.running = false;
        loader.command = ["cliphist", "decode", id];
        loader.running = true;
    }

    // Replace an entry with edited text: drop the original, then copy the new
    // text (wl-paste --watch stores it as a fresh entry). The text is passed as
    // an argument, so quotes and newlines in it are safe.
    function saveEdit(id, text) {
        if (!isId(id))
            return;
        action.command = [
            "sh", "-c",
            "cliphist list | awk -F '\\t' '$1 == \"" + id + "\"' | cliphist delete; printf %s \"$1\" | wl-copy",
            "sh",
            text
        ];
        action.running = true;
        refreshSoon.restart();
    }

    function run(script) {
        action.command = ["sh", "-c", script];
        action.running = true;
    }

    function parse(text) {
        return text.split("\n")
            .filter(line => line.length > 0)
            .slice(0, maxItems)
            .map(line => {
                const tab = line.indexOf("\t");
                return { id: line.slice(0, tab), text: line.slice(tab + 1) };
            })
            .filter(item => isId(item.id));
    }

    property Process watcher: Process {
        running: Settings.clipboardEnabled
        command: ["wl-paste", "--watch", "cliphist", "store"]
    }

    property Process listing: Process {
        command: ["cliphist", "list"]
        stdout: StdioCollector {
            onStreamFinished: root.items = root.parse(this.text)
        }
    }

    property Process loader: Process {
        stdout: StdioCollector {
            onStreamFinished: {
                root.editText = this.text;
                root.editLoaded(root.loadingId);
            }
        }
    }

    property Process action: Process {}

    property Timer refreshSoon: Timer {
        interval: 400
        onTriggered: root.refresh()
    }

    property Timer timer: Timer {
        interval: 2000
        running: Settings.clipboardEnabled
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }
}