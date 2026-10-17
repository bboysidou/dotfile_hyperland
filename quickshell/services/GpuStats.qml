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

    property string device: ""
    property string hwmon: ""
    property string name: ""

    property real busy: 0
    property real vramUsed: 0
    property real vramTotal: 0
    property real temp: 0
    property real power: 0
    property real powerCap: 0
    property real fan: 0
    property real fanRpm: 0
    property real clockMhz: 0
    property var processes: []

    property var previousGfx: ({})
    property real previousMs: 0

    readonly property bool available: root.device.length > 0
    readonly property int busyPercent: Num.toPercent(root.busy * Appearance.scale.percent)
    readonly property real vramFraction: root.vramTotal > 0 ? Num.clamp01(root.vramUsed / root.vramTotal) : 0

    readonly property var deviceFiles: ["gpu_busy_percent", "mem_info_vram_used", "mem_info_vram_total"]
    readonly property var hwmonFiles: ["temp1_input", "power1_input", "power1_average", "power1_cap", "pwm1", "pwm1_max", "fan1_input", "freq1_input"]

    function applyProbe(payload: string): void {
        const lines = payload.trim().split("\n");
        if (lines.length < 2 || lines[0].length === 0)
            return;

        const label = lines[2] ?? "";
        const bracket = /\[(.+)\]/.exec(label);

        root.device = lines[0];
        root.hwmon = lines[1];
        root.name = bracket ? bracket[1] : label;
    }

    function applyReadings(payload: string): void {
        const values = payload.trim().split("\n").map(value => value === "-" ? NaN : Number(value));
        const read = index => isFinite(values[index]) ? values[index] : 0;
        const config = Appearance.hardware;
        const pwmMax = read(8);

        root.busy = Num.clamp01(read(0) / Appearance.scale.percent);
        root.vramUsed = read(1);
        root.vramTotal = read(2);
        root.temp = read(3) / config.milliPerUnit;
        root.power = (read(4) || read(5)) / config.microPerUnit;
        root.powerCap = read(6) / config.microPerUnit;
        root.fan = pwmMax > 0 ? Num.clamp01(read(7) / pwmMax) : 0;
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

        root.previousGfx = {};
        processProc.running = true;
    }

    Process {
        running: true
        command: ["sh", "-c", Commands.gpuProbe]

        stdout: StdioCollector {
            onStreamFinished: root.applyProbe(text)
        }
    }

    Timer {
        interval: root.active ? Appearance.hardware.activePollInterval : Appearance.bar.usagePollInterval
        running: root.available
        repeat: true
        triggeredOnStart: true

        onTriggered: readProc.running = true
    }

    Timer {
        interval: Appearance.hardware.procPollInterval
        running: root.active
        repeat: true

        onTriggered: processProc.running = true
    }

    Process {
        id: readProc

        command: ["sh", "-c", Commands.readEach, "sh"].concat(root.deviceFiles.map(file => `${root.device}/${file}`), root.hwmonFiles.map(file => `${root.hwmon}/${file}`))

        stdout: StdioCollector {
            onStreamFinished: root.applyReadings(text)
        }
    }

    Process {
        id: processProc

        command: ["sh", "-c", Commands.gpuProcesses]

        stdout: StdioCollector {
            onStreamFinished: root.applyProcesses(text)
        }
    }
}
