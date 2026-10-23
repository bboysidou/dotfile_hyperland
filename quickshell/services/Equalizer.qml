pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import qs.core.config
import qs.core.helpers

Singleton {
    id: root

    property var gains: root.config.frequencies.map(() => 0)
    property var custom: root.config.frequencies.map(() => 0)
    property string preset: root.config.labelCustom
    property bool loaded: false
    property bool saved: true
    property bool dirty: false

    readonly property var config: Appearance.equalizer
    readonly property string stateDir: `${Paths.state}/${Appearance.state.dir}`
    readonly property var node: (Pipewire.nodes?.values ?? []).find(candidate => candidate.name === root.config.nodeName) ?? null
    readonly property bool available: root.node !== null
    readonly property var choices: root.config.presets.concat([[root.config.labelCustom, root.custom]])

    function clampGain(value: real): real {
        const step = root.config.gainStep;
        return Num.clamp(Math.round(value / step) * step, root.config.gainMin, root.config.gainMax);
    }

    function setGain(band: int, value: real): void {
        const next = root.gains.slice();
        next[band] = root.clampGain(value);
        root.gains = next;
        root.custom = next;
        root.preset = root.matchingPreset();
        root.touch();
    }

    function usePreset(name: string): void {
        const entry = root.choices.find(candidate => candidate[0] === name);
        if (!entry)
            return;
        root.gains = entry[1].slice();
        root.preset = name;
        root.touch();
    }

    function matchingPreset(): string {
        const entry = root.config.presets.find(candidate => candidate[1].every((gain, index) => gain === root.gains[index]));
        return entry ? entry[0] : root.config.labelCustom;
    }

    function touch(): void {
        root.saved = false;
        applier.restart();
        saver.restart();
    }

    function push(): void {
        if (!root.available)
            return;
        if (pusher.running) {
            root.dirty = true;
            return;
        }
        const params = root.gains.map((gain, index) => root.config.paramTemplate.arg(index + 1).arg(gain.toFixed(1))).join(" ");
        pusher.command = ["pw-cli", "set-param", String(root.node.id), "Props", root.config.propsTemplate.arg(params)];
        pusher.running = true;
    }

    function validGains(value: var): bool {
        return Array.isArray(value) && value.length === root.config.frequencies.length;
    }

    function adopt(payload: string): void {
        try {
            const data = JSON.parse(payload);
            if (root.validGains(data.gains))
                root.gains = data.gains.map(gain => root.clampGain(Number(gain)));
            root.custom = root.validGains(data.custom) ? data.custom.map(gain => root.clampGain(Number(gain))) : root.gains.slice();
            root.preset = root.matchingPreset();
        } catch (error) {
            root.preset = root.matchingPreset();
        }
        root.loaded = true;
        root.push();
    }

    onNodeChanged: {
        if (root.loaded)
            root.push();
    }

    PwObjectTracker {
        objects: root.node ? [root.node] : []
    }

    Timer {
        id: applier

        interval: root.config.applyDebounce

        onTriggered: root.push()
    }

    Timer {
        id: saver

        interval: root.config.saveDebounce

        onTriggered: {
            store.setText(JSON.stringify({
                gains: root.gains,
                custom: root.custom
            }));
            root.saved = true;
        }
    }

    Process {
        id: pusher

        onExited: {
            if (!root.dirty)
                return;
            root.dirty = false;
            root.push();
        }
    }

    Process {
        running: true

        command: ["mkdir", "-p", root.stateDir]
    }

    FileView {
        id: store

        path: `${root.stateDir}/${root.config.stateFile}`
        atomicWrites: true
        printErrors: false

        onLoaded: root.adopt(text())
        onLoadFailed: root.adopt("{}")
    }
}
