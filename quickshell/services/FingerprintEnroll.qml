pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.core.config
import qs.core.constants
import qs.core.enums

Singleton {
    id: root

    readonly property var config: Appearance.fingerprint
    readonly property string user: Quickshell.env("USER")

    property string phase: FingerprintPhase.idle
    property string finger: ""
    property string removing: ""
    property string message: ""
    property string detail: ""
    property int stage: 0
    property int stages: 0
    property bool completed: false

    signal retried

    readonly property bool enrolling: root.phase === FingerprintPhase.enrolling
    readonly property bool busy: root.enrolling || root.removing !== ""
    readonly property int total: root.stages > 0 ? root.stages : root.config.stagesFallback
    readonly property real progress: root.phase === FingerprintPhase.done ? 1 : Math.min(root.stage / root.total, 1)

    function start(target: string): void {
        if (root.busy)
            return;

        root.finger = target;
        root.stage = 0;
        root.stages = 0;
        root.message = "";
        root.detail = "";
        root.completed = false;
        root.phase = FingerprintPhase.enrolling;
        enroll.command = [...Commands.fingerprintEnroll, target, root.user];
        enroll.running = true;
    }

    function cancel(): void {
        root.message = "";
        root.phase = FingerprintPhase.idle;
        enroll.running = false;
    }

    function acknowledge(): void {
        if (root.enrolling)
            return;

        root.message = "";
        root.phase = FingerprintPhase.idle;
    }

    function remove(target: string): void {
        if (root.busy)
            return;

        root.message = "";
        root.removing = target;
        deleter.command = [...Commands.fingerprintDelete, target, root.user];
        deleter.running = true;
    }

    function read(line: string): void {
        if (!line.startsWith(root.config.resultPrefix)) {
            if (root.config.failureLine.test(line))
                root.detail = line.trim();
            return;
        }

        const status = line.slice(root.config.resultPrefix.length).trim();

        if (status === root.config.statusPassed) {
            root.stage += 1;
            root.message = "";
        } else if (status === root.config.statusCompleted) {
            root.completed = true;
            root.message = "";
        } else {
            root.message = root.config.statusMessages[status] ?? root.config.messageGeneric;
            root.retried();
        }
    }

    function finish(): void {
        if (!root.enrolling)
            return;

        if (root.completed) {
            root.phase = FingerprintPhase.done;
        } else {
            root.message = root.message || root.detail || root.config.messageGeneric;
            root.phase = FingerprintPhase.failed;
        }

        Fingerprint.refresh();
    }

    Process {
        id: enroll

        stdout: SplitParser {
            onRead: data => root.read(data)
        }

        onExited: root.finish()
    }

    Process {
        id: deleter

        onExited: code => {
            if (code !== 0)
                root.message = root.config.messageRemoveFailed;

            root.removing = "";
            Fingerprint.refresh();
        }
    }

    Process {
        id: stageQuery

        command: [...Commands.fingerprintQuery, root.config.propertyStages]

        stdout: StdioCollector {
            onStreamFinished: root.stages = Math.max(0, Number(text.trim().split(" ")[1]) || 0)
        }
    }

    Timer {
        running: root.enrolling && root.stages <= 0
        interval: root.config.stagesPollInterval
        repeat: true
        triggeredOnStart: true

        onTriggered: stageQuery.running = true
    }
}
