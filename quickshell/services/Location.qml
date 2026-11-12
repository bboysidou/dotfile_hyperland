pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.core.config
import qs.core.constants
import qs.core.helpers

Singleton {
    id: root

    property bool loaded: false
    property var pinned: null
    property var cached: null
    readonly property string stateDir: `${Paths.state}/${Appearance.state.dir}`
    readonly property string statePath: `${root.stateDir}/location.json`
    readonly property var place: root.pinned ?? Geo.detected ?? root.cached ?? LocationDefaults.fallbackPlace
    readonly property string source: root.pinned ? LocationDefaults.sourcePinned : Geo.detected ? LocationDefaults.sourceDetected : root.cached ? LocationDefaults.sourceCached : LocationDefaults.sourceFallback

    function pin(place: var): void {
        root.pinned = place;
        root.persist();
    }

    function unpin(): void {
        root.pinned = null;
        root.persist();
    }

    function adopt(payload: string): void {
        if (root.loaded)
            return;
        try {
            const data = JSON.parse(payload);
            root.pinned = data.pinned ?? null;
            root.cached = Geo.detected ?? data.cached ?? null;
        } catch (error) {}
        root.loaded = true;
    }

    function persist(): void {
        if (root.loaded)
            debounce.restart();
    }

    function flush(): void {
        store.setText(JSON.stringify({ pinned: root.pinned, cached: root.cached }));
    }

    Connections {
        target: Geo
        function onDetectedChanged(): void {
            if (Geo.detected) {
                root.cached = Geo.detected;
                root.persist();
            }
        }
    }

    Timer {
        id: debounce
        interval: LocationDefaults.saveDebounce
        onTriggered: root.flush()
    }

    Process {
        running: true
        command: ["mkdir", "-p", root.stateDir]
    }

    // Read the previous prayer-owned location only when no shared location exists.
    FileView {
        id: legacy
        path: `${root.stateDir}/${Appearance.prayer.stateFile}`
        preload: false
        blockLoading: true
        printErrors: false
    }

    FileView {
        id: store
        path: root.statePath
        atomicWrites: true
        printErrors: false
        onLoaded: root.adopt(text())
        onLoadFailed: root.adopt(legacy.text())
    }
}
