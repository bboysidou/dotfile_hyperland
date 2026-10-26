pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.core.config
import qs.core.constants
import qs.core.enums
import qs.core.helpers

Singleton {
    id: root

    readonly property var config: Appearance.settings
    readonly property string stateDir: `${Paths.state}/${Appearance.state.dir}`
    readonly property string statePath: `${root.stateDir}/${root.config.stateFile}`

    property bool loaded: false
    property var hiddenBar: []
    property var notifTimeouts: [Appearance.notif.timeoutLow, Appearance.notif.timeoutNormal, Appearance.notif.timeoutCritical]
    property string font: ""
    property real textScale: 1
    property var worldClocks: WorldClock.zones
    property int historyDays: Appearance.notif.historyMaxAgeDays
    property int historyMax: Appearance.notif.historyMaxEntries
    property int maxPopups: Appearance.notif.maxVisible
    property string barClock: Appearance.bar.clockFormat
    property string tempUnit: TempUnit.celsius
    property string windUnit: WindUnit.ms
    property int updateMinutes: Appearance.updates.pollMinutes
    property int mouseWarn: Appearance.powerPanel.warningPercent
    property var timezones: []

    function set(key: string, value: var): void {
        root[key] = value;
        root.persist();
    }

    function shown(entry: string): bool {
        return !root.hiddenBar.includes(entry);
    }

    function visibleEntries(entries: var): var {
        return entries.filter(entry => root.shown(entry));
    }

    function setShown(entry: string, on: bool): void {
        const rest = root.hiddenBar.filter(item => item !== entry);
        root.set("hiddenBar", on ? rest : rest.concat([entry]));
    }

    function stepTimeout(urgency: int, delta: int): void {
        const next = root.notifTimeouts.slice();
        next[urgency] = Num.clamp(next[urgency] + delta * root.config.timeoutStep, root.config.timeoutMin, root.config.timeoutMax);
        root.set("notifTimeouts", next);
    }

    function stepValue(key: string, delta: int, step: int, min: int, max: int): void {
        root.set(key, Num.clamp(root[key] + delta * step, min, max));
    }

    function stepScale(delta: int): void {
        const next = Math.round((root.textScale + delta * root.config.scaleStep) * Appearance.scale.percent) / Appearance.scale.percent;
        root.set("textScale", Num.clamp(next, root.config.scaleMin, root.config.scaleMax));
    }

    function zoneLabel(zone: string): string {
        return zone.slice(zone.lastIndexOf("/") + 1).replace(/_/g, " ");
    }

    function addClock(zone: string): void {
        if (root.worldClocks.length >= root.config.maxClocks || root.worldClocks.some(entry => entry.zone === zone))
            return;
        root.set("worldClocks", root.worldClocks.concat([
            {
                label: root.zoneLabel(zone),
                zone
            }
        ]));
    }

    function removeClock(zone: string): void {
        root.set("worldClocks", root.worldClocks.filter(entry => entry.zone !== zone));
    }

    function loadTimezones(): void {
        if (root.timezones.length === 0)
            zoneLister.running = true;
    }

    function adopt(payload: string): void {
        if (root.loaded)
            return;

        try {
            const state = JSON.parse(payload);
            root.hiddenBar = state.hiddenBar ?? root.hiddenBar;
            root.notifTimeouts = state.notifTimeouts ?? root.notifTimeouts;
            root.font = state.font ?? root.font;
            root.textScale = state.textScale ?? root.textScale;
            root.worldClocks = state.worldClocks ?? root.worldClocks;
            root.historyDays = state.historyDays ?? root.historyDays;
            root.historyMax = state.historyMax ?? root.historyMax;
            root.maxPopups = state.maxPopups ?? root.maxPopups;
            root.barClock = state.barClock ?? root.barClock;
            root.tempUnit = state.tempUnit ?? root.tempUnit;
            root.windUnit = state.windUnit ?? root.windUnit;
            root.updateMinutes = state.updateMinutes ?? root.updateMinutes;
            root.mouseWarn = state.mouseWarn ?? root.mouseWarn;
        } catch (parseError) {}

        root.loaded = true;
    }

    function persist(): void {
        if (root.loaded)
            debounce.restart();
    }

    function flush(): void {
        store.setText(JSON.stringify({
            hiddenBar: root.hiddenBar,
            notifTimeouts: root.notifTimeouts,
            font: root.font,
            textScale: root.textScale,
            worldClocks: root.worldClocks,
            historyDays: root.historyDays,
            historyMax: root.historyMax,
            maxPopups: root.maxPopups,
            barClock: root.barClock,
            tempUnit: root.tempUnit,
            windUnit: root.windUnit,
            updateMinutes: root.updateMinutes,
            mouseWarn: root.mouseWarn
        }));
    }

    Binding {
        target: Appearance.font.family
        property: "sans"
        value: root.font || Appearance.font.family.defaultSans
    }

    Binding {
        target: Appearance.font.size
        property: "scale"
        value: root.textScale
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

    Process {
        id: zoneLister

        command: Commands.timezones

        stdout: StdioCollector {
            onStreamFinished: root.timezones = text.split("\n").filter(line => line.length > 0)
        }
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
