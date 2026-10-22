pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.core.config
import qs.core.constants
import qs.core.helpers

Singleton {
    id: root

    property bool active: false
    property string url: ""
    property var events: []
    property bool loaded: false
    property bool failed: false

    readonly property var config: Appearance.weather
    readonly property string stateDir: `${Paths.state}/${Appearance.state.dir}`
    readonly property string statePath: `${root.stateDir}/${root.config.agendaFile}`
    readonly property bool configured: root.url !== ""

    function setUrl(value: string): void {
        root.url = value.trim();
        root.events = [];
        store.setText(JSON.stringify({
            url: root.url
        }));
        root.refresh();
    }

    function refresh(): void {
        if (!root.configured || fetcher.running)
            return;

        fetcher.command = Commands.fetch.concat([root.url]);
        fetcher.running = true;
    }

    function on(day): var {
        return Ics.occurrences(root.events, day);
    }

    function adopt(payload: string): void {
        try {
            root.url = JSON.parse(payload).url ?? "";
        } catch (error) {
            root.url = "";
        }
        root.loaded = true;
        root.refresh();
    }

    Timer {
        interval: root.config.agendaMinutes * root.config.minuteMs
        running: root.active && root.configured
        repeat: true

        onTriggered: root.refresh()
    }

    Process {
        id: fetcher

        stdout: StdioCollector {
            onStreamFinished: {
                root.failed = !text.includes("BEGIN:VCALENDAR");
                if (!root.failed)
                    root.events = Ics.parse(text);
            }
        }
    }

    Process {
        id: secure

        command: ["chmod", "600", root.statePath]
    }

    Process {
        running: true

        command: ["mkdir", "-p", root.stateDir]
    }

    FileView {
        id: store

        path: root.statePath
        atomicWrites: true
        printErrors: false

        onLoaded: root.adopt(text())
        onLoadFailed: root.adopt("{}")
        onSaved: secure.running = true
    }
}
