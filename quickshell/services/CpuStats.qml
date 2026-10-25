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

    property var cores: []
    property var coreAverages: []
    property real clockMhz: 0
    property real maxClockMhz: 0
    property real temp: 0
    property real power: -1
    property var processes: []

    property var previous: []
    property var samples: []

    readonly property int coreCount: root.previous.length
    readonly property int usagePercent: root.cores.length > 0 ? Num.toPercent(Appearance.scale.percent * root.cores.reduce((sum, value) => sum + value, 0) / root.cores.length) : 0

    readonly property var busiestCores: root.coreAverages.map((value, index) => ({
                index: index,
                value: value
            })).sort((a, b) => b.value - a.value).slice(0, Appearance.hardware.coreAverageMax)

    function counters(payload: string): var {
        return payload.split("\n").filter(line => /^cpu\d+ /.test(line)).map(line => {
            const fields = line.split(/\s+/).slice(1, 9).map(Number);
            const total = fields.reduce((sum, value) => sum + value, 0);

            return {
                total: total,
                busy: total - fields[3] - fields[4]
            };
        });
    }

    function applyStat(payload: string): void {
        const current = root.counters(payload);

        if (root.previous.length === current.length) {
            const deltas = current.map((entry, index) => ({
                        total: entry.total - root.previous[index].total,
                        busy: entry.busy - root.previous[index].busy
                    }));

            root.cores = deltas.map(delta => delta.total > 0 ? Num.clamp01(delta.busy / delta.total) : 0);
            root.record(deltas);
        }

        root.previous = current;
    }

    function record(deltas: var): void {
        const now = Date.now();
        const horizon = now - Appearance.hardware.coreAverageWindow;

        root.samples = root.samples.filter(sample => sample.time >= horizon).concat([
            {
                time: now,
                deltas: deltas
            }
        ]);

        root.coreAverages = deltas.map((_, index) => {
            let busy = 0;
            let total = 0;

            root.samples.forEach(sample => {
                busy += sample.deltas[index].busy;
                total += sample.deltas[index].total;
            });

            return total > 0 ? busy / total : 0;
        });
    }

    function applyClock(payload: string): void {
        const speeds = payload.split("\n").filter(line => line.startsWith("cpu MHz")).map(line => Number(line.split(":")[1]));

        if (speeds.length > 0)
            root.clockMhz = Math.max(...speeds);
    }

    function applyProcesses(payload: string): void {
        root.processes = payload.trim().split("\n").filter(line => line.length > 0).map(line => {
            const parts = line.split("\t");

            return {
                pid: parts[0],
                percent: Number(parts[1]),
                name: parts[2] ?? ""
            };
        });
    }

    onActiveChanged: {
        if (root.active)
            processProc.running = true;
    }

    Timer {
        interval: root.active ? Appearance.hardware.activePollInterval : PowerSource.poll(Appearance.hardware.idlePollInterval)
        running: true
        repeat: true
        triggeredOnStart: true

        onTriggered: {
            stat.reload();

            if (!root.active)
                return;

            cpuinfo.reload();
            power.reload();

            if (SysInfo.tempPath.length > 0)
                temp.reload();
        }
    }

    Timer {
        interval: Appearance.hardware.procPollInterval
        running: root.active
        repeat: true

        onTriggered: processProc.running = true
    }

    Process {
        id: processProc

        command: ["sh", "-c", Commands.cpuProcesses.arg(Appearance.hardware.procSampleDelay).arg(Appearance.hardware.procMax)]

        stdout: StdioCollector {
            onStreamFinished: root.applyProcesses(text)
        }
    }

    FileView {
        id: stat

        path: "/proc/stat"
        onLoaded: root.applyStat(text())
    }

    FileView {
        id: cpuinfo

        path: "/proc/cpuinfo"
        onLoaded: root.applyClock(text())
    }

    FileView {
        path: "/sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq"
        onLoaded: root.maxClockMhz = Number(text().trim()) / Appearance.hardware.khzPerMhz
    }

    FileView {
        id: temp

        path: SysInfo.tempPath
        onLoaded: root.temp = Number(text().trim()) / Appearance.hardware.milliPerUnit
    }

    FileView {
        id: power

        path: Paths.cpuPower
        printErrors: false
        onLoaded: root.power = Number(text().trim())
        onLoadFailed: root.power = -1
    }
}
