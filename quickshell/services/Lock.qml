pragma Singleton

import Quickshell
import Quickshell.Io
import Quickshell.Services.Pam
import qs.core.config
import qs.core.helpers

Singleton {
    id: root

    readonly property string user: Quickshell.env("USER")
    readonly property string stateDir: `${Paths.state}/${Appearance.state.dir}`
    readonly property string statePath: `${root.stateDir}/${Appearance.lock.stateFile}`

    property bool locked: false
    property bool unlocking: false
    property bool recovering: false
    property bool seeded: false
    property string buffer: ""
    property string message: ""
    property int failures: 0

    signal failed

    readonly property bool busy: pam.active
    readonly property bool coolingDown: root.failures >= Appearance.lock.faillockDeny

    readonly property string greeting: {
        const hour = Time.now.getHours();
        const config = Appearance.lock;

        if (hour >= config.hourMorning && hour < config.hourAfternoon)
            return config.greetingMorning;
        if (hour >= config.hourAfternoon && hour < config.hourEvening)
            return config.greetingAfternoon;
        if (hour >= config.hourEvening && hour < config.hourNight)
            return config.greetingEvening;
        if (hour >= config.hourNight)
            return config.greetingNight;

        return config.greetingLate;
    }

    readonly property string failureText: {
        if (root.failures === 0)
            return "";

        const template = root.failures === 1 ? Appearance.lock.failureSingular : Appearance.lock.failurePlural;
        return template.arg(root.failures);
    }

    function show(): void {
        root.reset();
        root.unlocking = false;
        root.recovering = false;
        root.locked = true;
    }

    function release(): void {
        root.reset();
        root.unlocking = false;
        root.locked = false;
    }

    function recover(): void {
        root.buffer = "";
        root.recovering = false;
    }

    function reset(): void {
        root.buffer = "";
        root.message = "";
    }

    function append(text: string): void {
        if (root.busy || root.coolingDown || root.unlocking || root.recovering)
            return;

        root.buffer += text;
    }

    function backspace(): void {
        if (root.unlocking || root.recovering)
            return;

        root.buffer = root.buffer.slice(0, -1);
    }

    function collect(text: string): void {
        const trimmed = text.trim();

        if (!trimmed)
            return;

        root.message = root.message ? `${root.message} ${trimmed}` : trimmed;
    }

    function authenticate(): void {
        if (!root.buffer || root.busy || root.unlocking || root.recovering)
            return;

        root.message = "";
        pam.start();
    }

    function persist(): void {
        state.setText(String(root.failures));
    }

    function finish(result): void {
        if (result === PamResult.Success) {
            root.failures = 0;
            root.persist();
            root.unlocking = true;
            return;
        }

        root.failures += 1;
        root.persist();
        root.recovering = true;
        root.failed();
    }

    PamContext {
        id: pam

        config: Appearance.lock.pamConfig

        onPamMessage: {
            if (pam.responseRequired)
                pam.respond(root.buffer);
            else
                root.collect(pam.message);
        }

        onCompleted: result => root.finish(result)
        onError: error => root.collect(PamError.toString(error))
    }

    FileView {
        id: state

        path: root.statePath
        atomicWrites: true
        watchChanges: true

        onFileChanged: reload()

        onLoaded: {
            const value = Number(text().trim());

            if (isFinite(value))
                root.failures = value;

            root.seeded = true;
        }

        onLoadFailed: {
            if (!root.seeded) {
                root.seeded = true;
                root.persist();
            }
        }
    }
}
