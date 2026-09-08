pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.core.config
import qs.core.helpers

Singleton {
    id: root

    property bool loaded: false
    property bool enabled: true

    readonly property string stateDir: `${Paths.state}/${Appearance.state.dir}`
    readonly property string statePath: `${root.stateDir}/${Appearance.notif.soundStateFile}`

    function play(): void {
        if (!root.enabled || player.running)
            return;

        player.running = true;
    }

    function toggle(): void {
        root.enabled = !root.enabled;
        root.persist();
    }

    function adopt(payload: string): void {
        try {
            root.enabled = JSON.parse(payload).enabled ?? true;
        } catch (parseError) {
            root.enabled = true;
        }

        root.loaded = true;
    }

    function persist(): void {
        if (root.loaded)
            debounce.restart();
    }

    function flush(): void {
        store.setText(JSON.stringify({
            enabled: root.enabled
        }));
    }

    Timer {
        id: debounce

        interval: Appearance.notif.soundSaveDebounce

        onTriggered: root.flush()
    }

    Process {
        id: player

        command: ["paplay", Appearance.notif.soundFile]
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
        onLoadFailed: root.loaded = true
    }
}
