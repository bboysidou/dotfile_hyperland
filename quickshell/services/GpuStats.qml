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

    property bool active: false

    property var cards: []
    property int selected: 0

    property bool suspended: false
    property real busy: NaN
    property real vramUsed: NaN
    property real vramTotal: NaN
    property real temp: NaN
    property real power: NaN
    property real powerCap: NaN
    property real fan: NaN
    property real fanRpm: NaN
    property real clockMhz: NaN
    property var processes: []

    property var previousGfx: ({})
    property real previousMs: 0
    property var previousCounter: null
    property var previousEnergy: null

    readonly property var card: root.cards[root.selected] ?? null
    readonly property string device: root.card?.device ?? ""
    readonly property string hwmon: root.card?.hwmon ?? ""
    readonly property string pci: root.card?.pci ?? ""
    readonly property string name: root.card?.name ?? ""
    readonly property string driver: root.card?.driver ?? ""
    readonly property string missing: root.card?.missing ?? ""

    readonly property bool available: root.cards.length > 0
    readonly property int busyPercent: isFinite(root.busy) ? Num.toPercent(root.busy * Appearance.scale.percent) : 0
    readonly property real vramFraction: root.vramTotal > 0 ? Num.clamp01(root.vramUsed / root.vramTotal) : 0
    readonly property real powerFraction: root.powerCap > 0 ? Num.clamp01(root.power / root.powerCap) : NaN

    function parseCard(line: string): var {
        const parts = line.split("\t");
        const label = (parts[5] ?? "").trim();
        const bracket = /\[(.+)\]/.exec(label);
        const name = bracket ? bracket[1] : label;

        return {
            device: parts[0],
            hwmon: parts[1] ?? "",
            pci: parts[2] ?? "",
            vram: Number(parts[3]) || 0,
            suspended: parts[4] === "suspended",
            name: name,
            driver: parts[6] ?? GpuDriver.none,
            missing: parts[7] ?? "",
            discrete: (parts[8] ?? "").trim(),
            dedicated: false
        };
    }

    function applyProbe(payload: string): void {
        const found = payload.trim().split("\n").filter(line => line.length > 0).map(line => root.parseCard(line));
        if (found.length === 0) {
            root.cards = [];
            return;
        }

        if (found.length > 1) {
            const rank = card => card.discrete === "1" ? Infinity : card.discrete === "0" ? -1 : card.vram;
            const largest = found.reduce((best, card) => rank(card) > rank(best) ? card : best, found[0]);
            largest.dedicated = true;
            found.sort((a, b) => a.dedicated - b.dedicated);
        }

        root.cards = found;
        root.select(root.preferredCard(found));
    }

    function preferredCard(found: var): int {
        const integrated = found.findIndex(card => !card.dedicated);
        if (PowerSource.onBattery && integrated >= 0)
            return integrated;

        const preferred = found.findIndex(card => card.dedicated && !card.suspended);
        const awake = found.findIndex(card => !card.suspended);
        return preferred >= 0 ? preferred : Math.max(0, awake);
    }

    function select(index: int): void {
        root.selected = index;
        root.suspended = false;
        root.clearReadings();
        root.processes = [];
        root.previousGfx = {};
        root.previousCounter = null;
        root.previousEnergy = null;

        if (!root.available)
            return;

        readProc.running = true;
        if (root.active)
            processProc.running = true;
    }

    function clearReadings(): void {
        root.busy = NaN;
        root.vramUsed = NaN;
        root.vramTotal = NaN;
        root.temp = NaN;
        root.power = NaN;
        root.powerCap = NaN;
        root.fan = NaN;
        root.fanRpm = NaN;
        root.clockMhz = NaN;
    }

    function applyReadings(payload: string): void {
        const lines = payload.trim().split("\n");
        const state = lines.shift();

        root.suspended = state === "suspended";
        root.clearReadings();

        if (root.suspended) {
            root.busy = 0;
            return;
        }

        if (state !== "active")
            return;

        const values = lines.map(value => value === "-" || value === "" ? NaN : Number(value));
        const read = index => isFinite(values[index]) ? values[index] : NaN;
        const config = Appearance.hardware;
        const pwmMax = read(8);

        root.busy = isFinite(read(0)) ? Num.clamp01(read(0) / Appearance.scale.percent) : NaN;
        root.vramUsed = read(1);
        root.vramTotal = read(2);
        root.temp = read(3) / config.milliPerUnit;
        root.power = (isFinite(read(4)) ? read(4) : read(5)) / config.microPerUnit;
        root.powerCap = read(6) / config.microPerUnit;
        root.fan = pwmMax > 0 ? Num.clamp01(read(7) / pwmMax) : NaN;
        root.fanRpm = read(9);
        root.clockMhz = read(10) / config.microPerUnit;

        if (!isFinite(root.busy))
            root.busy = root.counterBusy(lines[11] ?? "");
        if (!isFinite(root.power))
            root.power = root.energyPower(Number(lines[12]));
    }

    function energyPower(microJoules: real): real {
        const now = Date.now();
        const before = root.previousEnergy;

        if (!isFinite(microJoules)) {
            root.previousEnergy = null;
            return NaN;
        }

        root.previousEnergy = {
            value: microJoules,
            time: now
        };
        if (!before || microJoules < before.value || now <= before.time)
            return NaN;

        return (microJoules - before.value) / ((now - before.time) * Appearance.hardware.milliPerUnit);
    }

    function counterBusy(line: string): real {
        const parts = line.split("\t");
        const now = Date.now();
        const current = {
            kind: parts[0],
            work: Number(parts[1]),
            total: Number(parts[2]),
            time: now
        };
        const before = root.previousCounter;

        if (!GpuBusyKind.values.includes(current.kind) || !isFinite(current.work)) {
            root.previousCounter = null;
            return NaN;
        }

        root.previousCounter = current;
        if (!before || before.kind !== current.kind)
            return NaN;

        const work = current.work - before.work;
        const span = current.kind === GpuBusyKind.cycles ? current.total - before.total : (now - before.time) * Appearance.hardware.nsPerMs;

        return work >= 0 && span > 0 ? Num.clamp01(work / span) : NaN;
    }

    function rescan(): void {
        root.cards = [];
        root.selected = 0;
        root.clearReadings();
        root.processes = [];
        probeProc.running = true;
    }

    function applyProcesses(payload: string): void {
        const now = Date.now();
        const elapsedNs = (now - root.previousMs) * Appearance.hardware.nsPerMs;
        const previous = root.previousGfx;
        const next = {};

        const entries = payload.trim().split("\n").filter(line => line.length > 0).map(line => {
            const parts = line.split("\t");
            const kind = parts[1];
            const work = Number(parts[2]);
            const total = Number(parts[3]);
            const before = previous[parts[0]];

            next[parts[0]] = {
                work: work,
                total: total
            };

            return {
                pid: parts[0],
                busy: root.processBusy(kind, work, total, before, elapsedNs),
                vramKb: Number(parts[4]),
                name: parts[6] ?? ""
            };
        });

        root.previousGfx = next;
        root.previousMs = now;
        root.processes = entries.sort((a, b) => b.busy - a.busy || b.vramKb - a.vramKb).slice(0, Appearance.hardware.procMax);
    }

    function processBusy(kind: string, work: real, total: real, before: var, elapsedNs: real): real {
        if (kind === GpuBusyKind.pct)
            return Num.clamp01(work / Appearance.scale.percent);

        if (!before)
            return 0;

        const span = kind === GpuBusyKind.cycles ? total - before.total : elapsedNs;
        return span > 0 ? Num.clamp01((work - before.work) / span) : 0;
    }

    onActiveChanged: {
        if (!root.active)
            return;

        if (!root.available) {
            probeProc.running = true;
            return;
        }

        root.previousGfx = {};
        processProc.running = true;
    }

    Connections {
        target: PowerSource

        function onOnBatteryChanged(): void {
            if (PowerSource.onBattery && root.cards.length > 1)
                root.select(root.preferredCard(root.cards));
        }
    }

    Process {
        id: probeProc

        running: true
        command: Commands.gpu.concat(["probe"])

        stdout: StdioCollector {
            onStreamFinished: root.applyProbe(text)
        }
    }

    Timer {
        interval: Appearance.hardware.probeRetryInterval
        running: !root.available
        repeat: true

        onTriggered: probeProc.running = true
    }

    Timer {
        interval: root.active ? Appearance.hardware.activePollInterval : PowerSource.poll(Appearance.bar.usagePollInterval)
        running: root.available
        repeat: true
        triggeredOnStart: true

        onTriggered: readProc.running = true
    }

    Timer {
        interval: Appearance.hardware.procPollInterval
        running: root.active && root.available
        repeat: true

        onTriggered: processProc.running = true
    }

    Process {
        id: readProc

        command: Commands.gpu.concat(["read", root.driver, root.device, root.hwmon, root.pci])

        stdout: StdioCollector {
            onStreamFinished: root.applyReadings(text)
        }
    }

    Process {
        id: processProc

        command: Commands.gpu.concat(["procs", root.driver, root.device, root.pci])

        stdout: StdioCollector {
            onStreamFinished: root.applyProcesses(text)
        }
    }
}
