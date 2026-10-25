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

    readonly property var card: root.cards[root.selected] ?? null
    readonly property string device: root.card?.device ?? ""
    readonly property string hwmon: root.card?.hwmon ?? ""
    readonly property string pci: root.card?.pci ?? ""
    readonly property string name: root.card?.name ?? ""

    readonly property bool available: root.cards.length > 0
    readonly property int busyPercent: isFinite(root.busy) ? Num.toPercent(root.busy * Appearance.scale.percent) : 0
    readonly property real vramFraction: root.vramTotal > 0 ? Num.clamp01(root.vramUsed / root.vramTotal) : 0
    readonly property real powerFraction: root.powerCap > 0 ? Num.clamp01(root.power / root.powerCap) : NaN

    readonly property var deviceFiles: ["gpu_busy_percent", "mem_info_vram_used", "mem_info_vram_total"]
    readonly property var hwmonFiles: ["temp1_input", "power1_input", "power1_average", "power1_cap", "pwm1", "pwm1_max", "fan1_input", "freq1_input"]

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
            dedicated: false
        };
    }

    function applyProbe(payload: string): void {
        const found = payload.trim().split("\n").filter(line => line.length > 0).map(line => root.parseCard(line));
        if (found.length === 0)
            return;

        if (found.length > 1) {
            const largest = found.reduce((best, card) => card.vram > best.vram ? card : best, found[0]);
            largest.dedicated = true;
            found.sort((a, b) => a.dedicated - b.dedicated);
        }

        const preferred = found.findIndex(card => card.dedicated && !card.suspended);
        const awake = found.findIndex(card => !card.suspended);

        root.cards = found;
        root.select(preferred >= 0 ? preferred : Math.max(0, awake));
    }

    function select(index: int): void {
        root.selected = index;
        root.suspended = false;
        root.clearReadings();
        root.processes = [];
        root.previousGfx = {};

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
    }

    function applyProcesses(payload: string): void {
        const now = Date.now();
        const elapsedNs = (now - root.previousMs) * Appearance.hardware.nsPerMs;
        const previous = root.previousGfx;
        const next = {};

        const entries = payload.trim().split("\n").filter(line => line.length > 0).map(line => {
            const parts = line.split("\t");
            const gfx = Number(parts[1]);
            const before = previous[parts[0]];

            next[parts[0]] = gfx;

            return {
                pid: parts[0],
                busy: before !== undefined && elapsedNs > 0 ? Num.clamp01((gfx - before) / elapsedNs) : 0,
                vramKb: Number(parts[2]),
                name: parts[3] ?? ""
            };
        });

        root.previousGfx = next;
        root.previousMs = now;
        root.processes = entries.sort((a, b) => b.busy - a.busy || b.vramKb - a.vramKb).slice(0, Appearance.hardware.procMax);
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

    Process {
        id: probeProc

        running: true
        command: ["sh", "-c", Commands.gpuProbe]

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

        command: ["sh", "-c", Commands.gpuReadings, "sh", root.device].concat(root.deviceFiles.map(file => `${root.device}/${file}`), root.hwmonFiles.map(file => `${root.hwmon}/${file}`))

        stdout: StdioCollector {
            onStreamFinished: root.applyReadings(text)
        }
    }

    Process {
        id: processProc

        command: ["sh", "-c", Commands.gpuProcesses, "sh", root.pci]

        stdout: StdioCollector {
            onStreamFinished: root.applyProcesses(text)
        }
    }
}
