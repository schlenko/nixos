pragma Singleton

import QtQuick
import Quickshell.Io

// Synced lyrics for the current track from lrclib.net. The track title, artist,
// album and duration are sent to that service; disable with showLyrics=false.
QtObject {
    id: root

    // [{ time: seconds, text }], sorted by time
    property var lines: []
    property string lastKey: ""

    // Index of the line being sung, or -1 before the first line.
    readonly property int currentIndex: {
        let index = -1;
        for (let i = 0; i < lines.length && lines[i].time <= Media.position; i++)
            index = i;
        return index;
    }

    readonly property string currentText: currentIndex >= 0 ? lines[currentIndex].text : ""

    function fetch() {
        if (!Settings.showLyrics || !Media.title || !Media.artist) {
            lines = [];
            lastKey = "";
            return;
        }

        const key = [Media.title, Media.artist, Media.album, Math.round(Media.length)].join("|");
        if (key === lastKey)
            return;
        lastKey = key;
        lines = [];

        const exact = [
            "track_name=" + encodeURIComponent(Media.title),
            "artist_name=" + encodeURIComponent(Media.artist),
            "album_name=" + encodeURIComponent(Media.album),
            "duration=" + Math.round(Media.length)
        ];
        const fuzzy = [
            "track_name=" + encodeURIComponent(Media.title),
            "artist_name=" + encodeURIComponent(Media.artist)
        ];

        // A new track replaces any request still in flight. The exact lookup
        // runs first; if lrclib has no exact match, fall back to a search.
        request.running = false;
        request.command = [
            "sh", "-c",
            'curl -sf --max-time 8 "$1" || curl -sf --max-time 8 "$2"',
            "sh",
            "https://lrclib.net/api/get?" + exact.join("&"),
            "https://lrclib.net/api/search?" + fuzzy.join("&")
        ];
        request.running = true;
    }

    function parse(synced) {
        const parsed = [];
        for (const line of synced.split("\n")) {
            const match = /^\[(\d+):(\d+(?:\.\d+)?)\]\s*(.*)$/.exec(line.trim());
            if (match)
                parsed.push({ time: Number(match[1]) * 60 + Number(match[2]), text: match[3] });
        }
        return parsed;
    }

    // From a search result list, take the synced entry closest in length.
    function pick(results) {
        let best = null;
        let bestDiff = Infinity;
        for (const entry of results) {
            if (!entry.syncedLyrics)
                continue;
            const diff = Math.abs((entry.duration || 0) - Media.length);
            if (diff < bestDiff) {
                best = entry;
                bestDiff = diff;
            }
        }
        return best;
    }

    property Process request: Process {
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    let data = JSON.parse(this.text);
                    if (Array.isArray(data))
                        data = root.pick(data);
                    root.lines = data && data.syncedLyrics ? root.parse(data.syncedLyrics) : [];
                } catch (error) {
                    // Offline or nothing found: no lyrics for this track.
                    root.lines = [];
                }
            }
        }
    }

    // Metadata arrives in pieces, so wait for it to settle before fetching.
    property Timer debounce: Timer {
        interval: 400
        onTriggered: root.fetch()
    }

    property Connections trackWatch: Connections {
        target: Media
        function onTitleChanged() { root.debounce.restart(); }
        function onArtistChanged() { root.debounce.restart(); }
        function onAlbumChanged() { root.debounce.restart(); }
        function onLengthChanged() { root.debounce.restart(); }
    }
}