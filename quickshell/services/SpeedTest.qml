pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.core.config
import qs.core.constants
import qs.core.enums

Singleton {
    id: root

    property string phase: SpeedPhase.idle
    property real download: 0
    property real upload: 0
    property string error: ""
    property var samples: []
    property bool queued: false
    property string stderrText: ""
    property real finishedAt: 0

    readonly property bool running: root.phase === SpeedPhase.down || root.phase === SpeedPhase.up

    function start(): void {
        root.error = "";
        root.download = 0;
        root.upload = 0;
        root.finishedAt = 0;

        if (worker.running) {
            root.queued = true;
            root.phase = SpeedPhase.idle;
            worker.running = false;
            return;
        }

        root.begin(SpeedPhase.down);
    }

    function stop(): void {
        root.queued = false;
        if (root.running)
            root.phase = SpeedPhase.idle;
        worker.running = false;
    }

    function begin(next: string): void {
        root.phase = next;
        root.samples = [];
        root.stderrText = "";
        worker.command = Commands.speedTest.concat([next, String(Appearance.speedTest.phaseSeconds)]);
        worker.running = true;
    }

    function record(line: string): void {
        const value = parseFloat(line);
        if (!isFinite(value) || value < 0)
            return;

        root.samples = root.samples.concat([value]);
        if (root.phase === SpeedPhase.down)
            root.download = value;
        else if (root.phase === SpeedPhase.up)
            root.upload = value;
    }

    function settle(): void {
        const warmup = Appearance.speedTest.warmupSamples;
        const steady = root.samples.length > warmup ? root.samples.slice(warmup) : root.samples;
        const mean = steady.reduce((sum, value) => sum + value, 0) / Math.max(1, steady.length);

        if (root.phase === SpeedPhase.down)
            root.download = mean;
        else
            root.upload = mean;
    }

    function finish(exitCode: int): void {
        if (root.queued) {
            root.queued = false;
            root.begin(SpeedPhase.down);
            return;
        }

        if (!root.running)
            return;

        if (exitCode !== 0) {
            root.error = root.stderrText || Appearance.speedTest.labelFailed;
            root.phase = SpeedPhase.idle;
            return;
        }

        root.settle();
        if (root.phase === SpeedPhase.down) {
            root.begin(SpeedPhase.up);
            return;
        }

        root.finishedAt = Date.now();
        root.phase = SpeedPhase.done;
    }

    Process {
        id: worker

        stdout: SplitParser {
            onRead: data => root.record(data)
        }

        stderr: StdioCollector {
            onStreamFinished: {
                root.stderrText = text.trim();
                if (root.error !== "" && root.stderrText !== "")
                    root.error = root.stderrText;
            }
        }

        onExited: exitCode => root.finish(exitCode)
    }
}
