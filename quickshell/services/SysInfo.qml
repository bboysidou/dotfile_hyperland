pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.core.config
import qs.core.helpers

Singleton {
    id: root

    property bool detailed: false

    property int cpuPercent: 0
    property int memPercent: 0
    property real memUsedKb: 0
    property real memTotalKb: 0
    property real swapUsedKb: 0
    property real swapTotalKb: 0

    property string cpuName: ""
    property real cpuTemp: 0
    property string tempPath: ""

    property var storage: []

    property real netDownRate: 0
    property real netUpRate: 0
    property var netDownHistory: []
    property var netUpHistory: []

    property real previousTotal: -1
    property real previousBusy: 0
    property bool primed: false

    property real previousRx: -1
    property real previousTx: 0
    property real previousNetMs: 0

    function applyCpu(payload: string): void {
        const fields = payload.split("\n")[0].split(" ").filter(part => part.length > 0).slice(1).map(Number);
        if (fields.length < 8)
            return;

        const total = fields.slice(0, 8).reduce((sum, value) => sum + value, 0);
        const busy = total - fields[3] - fields[4];

        if (previousTotal < 0) {
            previousTotal = total;
            previousBusy = busy;
            primeTimer.start();
            return;
        }

        const deltaTotal = total - previousTotal;
        const deltaBusy = busy - previousBusy;

        previousTotal = total;
        previousBusy = busy;
        primed = true;

        root.cpuPercent = deltaTotal > 0 ? Num.toPercent(Appearance.scale.percent * deltaBusy / deltaTotal) : 0;
    }

    function applyMemory(payload: string): void {
        const read = key => {
            const match = payload.match(new RegExp(`^${key}:\\s+(\\d+)`, "m"));
            return match ? Number(match[1]) : 0;
        };

        const total = read("MemTotal");
        if (total <= 0)
            return;

        root.memTotalKb = total;
        root.memUsedKb = total - read("MemAvailable");
        root.swapTotalKb = read("SwapTotal");
        root.swapUsedKb = root.swapTotalKb - read("SwapFree");
        root.memPercent = Num.toPercent(Appearance.scale.percent * root.memUsedKb / total);
    }

    function applyCpuInfo(payload: string): void {
        const match = /^model name\s*:\s*(.+)$/m.exec(payload);
        if (match)
            root.cpuName = match[1].trim();
    }

    function applyTemp(payload: string): void {
        const value = Number(payload.trim());
        if (isFinite(value))
            root.cpuTemp = value / 1000;
    }

    function applyStorage(payload: string): void {
        const seen = {};

        payload.trim().split("\n").slice(1).forEach(line => {
            const parts = line.trim().split(/\s+/);
            if (parts.length < 4)
                return;

            const source = parts[0];
            const target = parts[1];
            const size = Number(parts[2]);
            const used = Number(parts[3]);

            if (!isFinite(size) || size <= 0)
                return;

            const existing = seen[source];
            if (existing && existing.target.length <= target.length)
                return;

            seen[source] = {
                source: source,
                target: target,
                size: size,
                used: used,
                fraction: Num.clamp(used / size, 0, 1)
            };
        });

        root.storage = Object.keys(seen).map(key => seen[key]).sort((a, b) => b.size - a.size).slice(0, Appearance.dash.storageMax);
    }

    function applyNet(payload: string): void {
        let rx = 0;
        let tx = 0;

        payload.split("\n").slice(2).forEach(line => {
            const parts = line.trim().split(/\s+/);
            if (parts.length < 10)
                return;

            const name = parts[0].replace(":", "");
            if (name === "lo" || name.startsWith("veth") || name.startsWith("docker") || name.startsWith("br-"))
                return;

            rx += Number(parts[1]);
            tx += Number(parts[9]);
        });

        const nowMs = Date.now();

        if (root.previousRx < 0) {
            root.previousRx = rx;
            root.previousTx = tx;
            root.previousNetMs = nowMs;
            return;
        }

        const elapsed = (nowMs - root.previousNetMs) / 1000;
        if (elapsed <= 0)
            return;

        root.netDownRate = Math.max(0, (rx - root.previousRx) / elapsed);
        root.netUpRate = Math.max(0, (tx - root.previousTx) / elapsed);

        root.previousRx = rx;
        root.previousTx = tx;
        root.previousNetMs = nowMs;

        root.netDownHistory = Num.pushCapped(root.netDownHistory, root.netDownRate, Appearance.dash.netHistory);
        root.netUpHistory = Num.pushCapped(root.netUpHistory, root.netUpRate, Appearance.dash.netHistory);
    }

    onDetailedChanged: {
        if (!root.detailed)
            return;

        root.previousRx = -1;
        storageProc.running = true;
    }

    Timer {
        interval: Appearance.bar.usagePollInterval
        running: !root.detailed
        repeat: true
        triggeredOnStart: true

        onTriggered: {
            stat.reload();
            meminfo.reload();
        }
    }

    Timer {
        interval: Appearance.dash.detailPollInterval
        running: root.detailed
        repeat: true
        triggeredOnStart: true

        onTriggered: {
            stat.reload();
            meminfo.reload();
            netdev.reload();

            if (root.tempPath.length > 0)
                temp.reload();
        }
    }

    Timer {
        interval: Appearance.bar.usagePollInterval
        running: root.detailed
        repeat: true

        onTriggered: storageProc.running = true
    }

    Timer {
        id: primeTimer

        interval: Appearance.bar.usagePrimeDelay
        repeat: false

        onTriggered: stat.reload()
    }

    Process {
        running: true
        command: ["sh", "-c", 'for h in /sys/class/hwmon/*/; do n=$(cat "$h/name" 2>/dev/null); case "$n" in k10temp|coretemp|zenpower) echo "${h}temp1_input"; exit 0;; esac; done']

        stdout: StdioCollector {
            onStreamFinished: root.tempPath = text.trim()
        }
    }

    Process {
        id: storageProc

        command: ["df", "-B1", "--output=source,target,size,used", "-x", "tmpfs", "-x", "devtmpfs", "-x", "efivarfs", "-x", "overlay", "-x", "squashfs"]

        stdout: StdioCollector {
            onStreamFinished: root.applyStorage(text)
        }
    }

    FileView {
        id: stat

        path: "/proc/stat"
        onLoaded: root.applyCpu(text())
    }

    FileView {
        id: meminfo

        path: "/proc/meminfo"
        onLoaded: root.applyMemory(text())
    }

    FileView {
        path: "/proc/cpuinfo"
        onLoaded: root.applyCpuInfo(text())
    }

    FileView {
        id: netdev

        path: "/proc/net/dev"
        onLoaded: root.applyNet(text())
    }

    FileView {
        id: temp

        path: root.tempPath
        onLoaded: root.applyTemp(text())
    }
}
