pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.core.config
import qs.core.helpers

Singleton {
    id: root

    property var positions: ({})
    property bool loaded: false

    function extended(monitors): bool {
        return monitors.length > 1 && monitors.every(entry => !entry.settings.disabled && !entry.settings.mirror);
    }

    function capture(): void {
        if (!root.loaded || Displays.confirming || !root.extended(Displays.monitors))
            return;

        const next = {};
        for (const entry of Displays.monitors)
            next[entry.name] = {
                x: entry.settings.x,
                y: entry.settings.y
            };

        if (JSON.stringify(next) === JSON.stringify(root.positions))
            return;

        root.positions = next;
        store.setText(JSON.stringify(next));
    }

    function adopt(payload: string): void {
        try {
            root.positions = JSON.parse(payload) ?? {};
        } catch (parseError) {
            root.positions = {};
        }
        root.loaded = true;
        root.capture();
    }

    Connections {
        target: Displays

        function onMonitorsChanged(): void {
            root.capture();
        }

        function onConfirmingChanged(): void {
            root.capture();
        }
    }

    FileView {
        id: store

        path: `${Paths.state}/${Appearance.state.dir}/${Appearance.display.layoutStateFile}`
        atomicWrites: true
        printErrors: false

        onLoaded: root.adopt(text())
        onLoadFailed: root.adopt("")
    }
}
