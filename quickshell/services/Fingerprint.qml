pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pam
import qs.core.config
import qs.core.constants

Singleton {
    id: root

    property bool wanted: false
    property bool installed: true
    property bool present: false
    property bool sudoEnabled: false
    property string deviceName: ""
    property var fingers: []
    property bool mismatched: false
    property bool reading: false
    property real readEstimate: Appearance.lock.readEstimate
    property double readStarted: 0
    property int tries: 0
    property int errors: 0

    signal matched
    signal rejected
    signal abandoned

    readonly property bool enrolled: root.fingers.length > 0
    readonly property bool scanning: pam.active
    readonly property bool exhausted: root.tries >= Appearance.lock.fingerprintMaxTries
    readonly property bool failing: root.errors >= Appearance.lock.fingerprintErrorRetries
    readonly property bool usable: root.wanted && root.enrolled && !root.exhausted && !root.failing

    readonly property string hint: {
        if (!root.wanted || !root.enrolled || root.failing)
            return "";
        if (root.exhausted)
            return Appearance.lock.fingerprintExhausted;
        if (root.mismatched)
            return Appearance.lock.fingerprintMismatch;

        return Appearance.lock.fingerprintPrompt;
    }

    function refresh(): void {
        detect.running = true;
        sudoCheck.running = true;
    }

    function parse(listing: string): var {
        return listing.split("\n").map(line => Commands.fingerprintFinger.exec(line)?.[1]).filter(finger => finger);
    }

    function begin(): void {
        root.wanted = true;
        root.mismatched = false;
        root.tries = 0;
        root.errors = 0;
        detect.running = true;
    }

    function end(): void {
        root.wanted = false;
        root.reading = false;
        grace.stop();
        retry.stop();
        pam.abort();
    }

    function noteFinger(present: bool): void {
        if (!present) {
            if (root.reading)
                grace.restart();
            return;
        }

        grace.stop();

        if (root.reading || !pam.active)
            return;

        root.readStarted = Date.now();
        root.reading = true;
    }

    function learn(): void {
        if (!root.reading)
            return;

        const config = Appearance.lock;
        const elapsed = Date.now() - root.readStarted;
        root.readEstimate = Math.max(config.readEstimateMin, Math.min(config.readEstimateMax, (root.readEstimate + elapsed) / 2));
    }

    function rescan(): void {
        root.reading = false;
        grace.stop();
        retry.stop();
        pam.abort();
        root.errors = 0;
        root.scan();
    }

    function scan(): void {
        if (!root.wanted || !root.enrolled || root.exhausted || root.failing || pam.active)
            return;

        root.mismatched = false;

        if (!pam.start())
            root.finish(PamResult.Error);
    }

    function finish(result): void {
        grace.stop();

        if (result === PamResult.Success) {
            root.learn();
            root.reading = false;
            root.wanted = false;
            root.matched();
            return;
        }

        const wasReading = root.reading;

        root.reading = false;

        if (result === PamResult.MaxTries || result === PamResult.Failed) {
            root.tries += 1;
            root.mismatched = true;
            root.rejected();
        } else {
            root.errors += 1;

            if (wasReading)
                root.abandoned();
        }

        retry.restart();
    }

    Timer {
        id: grace

        interval: Appearance.lock.readGrace

        onTriggered: {
            root.reading = false;
            root.abandoned();
        }
    }

    Process {
        running: root.wanted && root.enrolled

        command: Commands.fingerprintMonitor

        stdout: SplitParser {
            onRead: data => {
                const present = Commands.fingerprintPresent.exec(data);

                if (present)
                    root.noteFinger(present[1] === "true");
            }
        }
    }

    Timer {
        id: retry

        interval: Appearance.lock.fingerprintRetryDelay

        onTriggered: root.scan()
    }

    PamContext {
        id: pam

        config: Appearance.lock.fingerprintPamConfig
        configDirectory: `${Quickshell.shellDir}/${Appearance.lock.pamDir}`

        onCompleted: result => root.finish(result)
    }

    Process {
        id: detect

        command: Commands.fingerprintList

        stdout: StdioCollector {
            onStreamFinished: {
                root.fingers = root.parse(text);
                root.scan();
            }
        }

        onExited: code => {
            root.installed = code !== Appearance.fingerprint.commandMissing;
            root.present = code === 0;

            if (root.present)
                name.running = true;
            else
                root.deviceName = "";
        }
    }

    Process {
        id: name

        command: [...Commands.fingerprintQuery, Appearance.fingerprint.propertyName]

        stdout: StdioCollector {
            onStreamFinished: root.deviceName = text.split("\"")[1] ?? ""
        }
    }

    Process {
        id: sudoCheck

        command: Commands.fingerprintSudoCheck

        onExited: code => root.sudoEnabled = code === 0
    }
}
