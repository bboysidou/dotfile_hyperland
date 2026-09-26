pragma Singleton

import QtQuick
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
    property bool aborted: false
    property int focusHolders: 0
    property string buffer: ""
    property string message: ""
    property int failures: 0
    property double lastFailure: 0
    property double cooldownUntil: 0
    property double now: Date.now()

    signal failed

    readonly property bool busy: pam.active
    readonly property bool focused: root.focusHolders > 0
    readonly property int cooldown: Math.max(0, Math.ceil((root.cooldownUntil - root.now) / Appearance.lock.faillockTick))
    readonly property bool coolingDown: root.cooldown > 0

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
        if (root.coolingDown)
            return Appearance.lock.cooldownTemplate.arg(root.cooldown);

        if (root.failures === 0)
            return "";

        const template = root.failures === 1 ? Appearance.lock.failureSingular : Appearance.lock.failurePlural;
        return template.arg(root.failures);
    }

    function tick(): void {
        root.now = Date.now();
    }

    function show(): void {
        root.tick();
        root.reset();
        root.unlocking = false;
        root.recovering = false;
        root.focusHolders = 0;
        root.locked = true;
        root.persist();
    }

    function release(): void {
        root.reset();
        root.unlocking = false;
        root.focusHolders = 0;
        root.locked = false;
        root.persist();
    }

    function recover(): void {
        recovery.stop();
        root.buffer = "";
        root.recovering = false;
    }

    function reset(): void {
        root.buffer = "";
        root.message = "";
    }

    function append(text: string): void {
        if (root.busy || root.unlocking || root.recovering)
            return;

        root.tick();

        if (root.coolingDown)
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

        root.tick();

        if (root.coolingDown)
            return;

        root.message = "";
        root.aborted = false;

        if (!pam.start()) {
            root.collect(Appearance.lock.pamUnavailable);
            root.buffer = "";
            return;
        }

        watchdog.restart();
    }

    function expire(): void {
        if (!pam.active)
            return;

        root.aborted = true;
        pam.abort();
        root.collect(Appearance.lock.pamTimedOut);
        root.buffer = "";
    }

    function persist(): void {
        state.setText(JSON.stringify({
            failures: root.failures,
            lastFailure: root.lastFailure,
            cooldownUntil: root.cooldownUntil,
            locked: root.locked
        }));
    }

    function parse(data: string): var {
        const fallback = {
            failures: 0,
            lastFailure: 0,
            cooldownUntil: 0,
            locked: false
        };

        const trimmed = data.trim();

        if (!trimmed)
            return fallback;

        try {
            const parsed = JSON.parse(trimmed);

            if (typeof parsed !== "object" || parsed === null) {
                const plain = Number(parsed);

                fallback.failures = isFinite(plain) ? plain : 0;
                return fallback;
            }

            return {
                failures: Number(parsed.failures) || 0,
                lastFailure: Number(parsed.lastFailure) || 0,
                cooldownUntil: Number(parsed.cooldownUntil) || 0,
                locked: parsed.locked === true
            };
        } catch (error) {
            const legacy = Number(trimmed);

            fallback.failures = isFinite(legacy) ? legacy : 0;
            return fallback;
        }
    }

    function adopt(data: string): void {
        const parsed = root.parse(data);

        root.failures = parsed.failures;
        root.lastFailure = parsed.lastFailure;
        root.cooldownUntil = parsed.cooldownUntil;
        root.seeded = true;

        if (parsed.locked && !root.locked)
            root.show();
    }

    function penalise(): void {
        const deny = Appearance.lock.faillockDeny;

        if (root.failures < deny || root.failures % deny !== 0)
            return;

        const steps = root.failures / deny;
        const seconds = Math.min(Appearance.lock.faillockCooldown * steps, Appearance.lock.faillockCooldownMax);
        root.cooldownUntil = root.now + seconds * Appearance.lock.faillockTick;
    }

    function finish(result): void {
        watchdog.stop();

        if (root.aborted) {
            root.aborted = false;
            return;
        }

        if (result === PamResult.Success) {
            root.failures = 0;
            root.lastFailure = 0;
            root.cooldownUntil = 0;
            root.persist();
            root.unlocking = true;
            return;
        }

        root.tick();

        if (root.lastFailure > 0 && root.now - root.lastFailure > Appearance.lock.faillockWindow)
            root.failures = 0;

        root.failures += 1;
        root.lastFailure = root.now;
        root.penalise();
        root.persist();
        root.recovering = true;
        recovery.restart();
        root.failed();
    }

    Timer {
        running: root.locked && root.cooldownUntil > root.now
        interval: Appearance.lock.faillockTick
        repeat: true

        onTriggered: root.tick()
    }

    Timer {
        id: recovery

        interval: Appearance.lock.recoverTimeout

        onTriggered: root.recover()
    }

    Timer {
        id: watchdog

        interval: Appearance.lock.pamTimeout

        onTriggered: root.expire()
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

    Process {
        running: true

        command: ["mkdir", "-p", root.stateDir]
    }

    FileView {
        id: state

        path: root.statePath
        atomicWrites: true
        watchChanges: true
        printErrors: false

        onFileChanged: reload()

        onLoaded: root.adopt(text())

        onLoadFailed: {
            if (!root.seeded) {
                root.seeded = true;
                root.persist();
            }
        }
    }
}
