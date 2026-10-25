pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower
import qs.core.config
import qs.core.helpers

Singleton {
    id: root

    property bool loaded: false
    property var chosen: ({})

    readonly property var config: Appearance.powerSource
    readonly property bool onBattery: UPower.onBattery
    readonly property string source: root.onBattery ? root.config.battery : root.config.ac
    readonly property string stateDir: `${Paths.state}/${Appearance.state.dir}`
    readonly property string statePath: `${root.stateDir}/${root.config.stateFile}`

    function poll(interval: int): int {
        return root.onBattery ? interval * root.config.batteryPollFactor : interval;
    }

    function fallback(): int {
        if (!root.onBattery && PowerProfiles.hasPerformanceProfile)
            return PowerProfile.Performance;
        return PowerProfile.Balanced;
    }

    function sync(): void {
        root.apply(true);
    }

    function apply(initial: bool): void {
        if (!root.loaded || (root.onBattery && LowPower.automatic))
            return;

        let wanted = root.chosen[root.source];
        if (wanted === undefined && initial) {
            root.remember();
            return;
        }
        if (wanted === undefined)
            wanted = root.fallback();
        if (PowerProfiles.profile !== wanted)
            PowerProfiles.profile = wanted;
    }

    function remember(): void {
        if (!root.loaded || LowPower.automatic || root.chosen[root.source] === PowerProfiles.profile)
            return;

        const next = Object.assign({}, root.chosen);
        next[root.source] = PowerProfiles.profile;
        root.chosen = next;
        debounce.restart();
    }

    function adopt(payload: string): void {
        try {
            const parsed = JSON.parse(payload);
            root.chosen = parsed && typeof parsed === "object" ? parsed : {};
        } catch (parseError) {
            root.chosen = {};
        }

        root.loaded = true;
        root.apply(true);
    }

    onOnBatteryChanged: root.apply(false)

    Connections {
        target: PowerProfiles

        function onProfileChanged(): void {
            root.remember();
        }
    }

    Timer {
        id: debounce

        interval: root.config.saveDebounce

        onTriggered: store.setText(JSON.stringify(root.chosen))
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
        onLoadFailed: root.adopt("")
    }
}
