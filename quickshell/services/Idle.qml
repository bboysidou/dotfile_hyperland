pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.core.config
import qs.core.constants
import qs.core.helpers

Singleton {
    id: root

    readonly property var config: Appearance.idle

    property bool loaded: false
    property bool enabled: Quickshell.env(root.config.env) === root.config.envEnabled
    property bool lockOn: true
    property bool screenOffOn: true
    property bool suspendOn: true
    property bool batteryOnly: true
    property int lockSeconds: root.config.lockSeconds
    property int screenOffSeconds: root.config.screenOffSeconds
    property int suspendSeconds: root.config.suspendSeconds

    readonly property string stateDir: `${Paths.state}/${Appearance.state.dir}`
    readonly property string statePath: `${root.stateDir}/${root.config.stateFile}`

    function set(key: string, value: var): void {
        root[key] = value;
        root.persist();
    }

    function label(seconds: int): string {
        const hours = Math.floor(seconds / Units.secondsPerHour);
        const minutes = Math.floor(seconds % Units.secondsPerHour / Units.secondsPerMinute);
        const secs = seconds % Units.secondsPerMinute;

        if (hours > 0)
            return minutes > 0 ? root.config.hoursMinutesTemplate.arg(hours).arg(minutes) : root.config.hoursTemplate.arg(hours);

        if (minutes === 0)
            return root.config.secondsTemplate.arg(secs);

        return secs > 0 ? root.config.minutesSecondsTemplate.arg(minutes).arg(secs) : root.config.minutesTemplate.arg(minutes);
    }

    function step(key: string, delta: int): void {
        const seconds = root[key];
        const size = root.config.steps.find(entry => delta > 0 ? seconds < entry[0] : seconds <= entry[0])?.[1] ?? root.config.minSeconds;
        const next = delta > 0 ? Math.floor(seconds / size) * size + size : Math.ceil(seconds / size) * size - size;

        root.set(key, Num.clamp(next, root.config.minSeconds, root.config.maxSeconds));
    }

    function adopt(payload: string): void {
        if (root.loaded)
            return;

        try {
            const state = JSON.parse(payload);
            root.enabled = state.enabled ?? root.enabled;
            root.lockOn = state.lockOn ?? root.lockOn;
            root.screenOffOn = state.screenOffOn ?? root.screenOffOn;
            root.suspendOn = state.suspendOn ?? root.suspendOn;
            root.batteryOnly = state.batteryOnly ?? root.batteryOnly;
            root.lockSeconds = state.lockSeconds ?? root.lockSeconds;
            root.screenOffSeconds = state.screenOffSeconds ?? root.screenOffSeconds;
            root.suspendSeconds = state.suspendSeconds ?? root.suspendSeconds;
        } catch (parseError) {}

        root.loaded = true;
    }

    function persist(): void {
        if (root.loaded)
            debounce.restart();
    }

    function flush(): void {
        store.setText(JSON.stringify({
            enabled: root.enabled,
            lockOn: root.lockOn,
            screenOffOn: root.screenOffOn,
            suspendOn: root.suspendOn,
            batteryOnly: root.batteryOnly,
            lockSeconds: root.lockSeconds,
            screenOffSeconds: root.screenOffSeconds,
            suspendSeconds: root.suspendSeconds
        }));
    }

    Timer {
        id: debounce

        interval: root.config.saveDebounce

        onTriggered: root.flush()
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
