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
    property bool restored: false
    property bool failed: false
    property int limit: 0
    property string chargeType: ""

    readonly property var config: Appearance.batteryTab
    readonly property string stateDir: `${Paths.state}/${Appearance.state.dir}`
    readonly property string statePath: `${root.stateDir}/${root.config.stateFile}`

    readonly property bool hasLimit: Battery.info[root.config.attrEnd] !== undefined
    readonly property bool canLimit: Battery.writable(root.config.attrEnd)
    readonly property bool canStart: Battery.writable(root.config.attrStart)
    readonly property bool hasHold: Battery.behaviour.options.includes(root.config.behaviourHold)
    readonly property bool canHold: root.hasHold && Battery.writable(root.config.attrBehaviour)
    readonly property bool holding: Battery.behaviour.current === root.config.behaviourHold
    readonly property bool hasMode: Battery.chargeTypes.options.length > 1
    readonly property bool canMode: root.hasMode && Battery.writable(root.config.attrTypes)
    readonly property bool supported: root.hasLimit || root.hasHold || root.hasMode
    readonly property bool locked: root.supported && !root.canLimit && !root.canHold && !root.canMode

    function limitPairs(end: int): var {
        const pairs = [[root.config.attrEnd, end]];
        if (!root.canStart)
            return pairs;

        const start = [root.config.attrStart, Math.max(0, end - root.config.limitHysteresis)];
        return end > Battery.limit ? pairs.concat([start]) : [start].concat(pairs);
    }

    function write(pairs: var): void {
        if (writer.running || Battery.sysfs === "" || pairs.length === 0)
            return;

        writer.command = ["sh", "-c", Commands.batteryWrite, "sh", Battery.sysfs].concat(pairs.flat().map(String));
        writer.running = true;
    }

    function setLimit(end: int): void {
        if (!root.canLimit)
            return;

        root.limit = end;
        root.persist();
        root.write(root.limitPairs(end));
    }

    function setHold(on: bool): void {
        if (root.canHold)
            root.write([[root.config.attrBehaviour, on ? root.config.behaviourHold : root.config.behaviourAuto]]);
    }

    function setChargeType(type: string): void {
        if (!root.canMode)
            return;

        root.chargeType = type;
        root.persist();
        root.write([[root.config.attrTypes, type]]);
    }

    function restore(): void {
        if (root.restored || !root.loaded || Battery.sysfs === "" || Object.keys(Battery.info).length === 0)
            return;

        root.restored = true;
        let pairs = [];
        if (root.limit > 0 && root.canLimit && Battery.limit !== root.limit)
            pairs = pairs.concat(root.limitPairs(root.limit));
        if (root.chargeType !== "" && root.canMode && Battery.chargeTypes.current !== root.chargeType && Battery.chargeTypes.options.includes(root.chargeType))
            pairs.push([root.config.attrTypes, root.chargeType]);
        root.write(pairs);
    }

    function adopt(payload: string): void {
        try {
            const stored = JSON.parse(payload);
            root.limit = Number(stored.limit ?? 0);
            root.chargeType = stored.chargeType ?? "";
        } catch (parseError) {
            root.limit = 0;
            root.chargeType = "";
        }

        root.loaded = true;
        root.restore();
    }

    function persist(): void {
        if (root.loaded)
            debounce.restart();
    }

    function flush(): void {
        store.setText(JSON.stringify({
            limit: root.limit,
            chargeType: root.chargeType
        }));
    }

    Connections {
        target: Battery

        function onInfoChanged(): void {
            root.restore();
        }
    }

    Timer {
        id: debounce

        interval: root.config.saveDebounce

        onTriggered: root.flush()
    }

    Process {
        id: writer

        onExited: code => {
            root.failed = code !== 0;
            Battery.refresh();
        }
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
        onLoadFailed: {
            root.loaded = true;
            root.restore();
        }
    }
}
