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

    readonly property var config: Appearance.settings
    readonly property string flagDir: `${Paths.state}/${Appearance.state.dir}`
    readonly property var specs: root.config.services.map(entry => `${entry.id}|${entry.kind}|${root.target(entry)}`)

    property bool polling: false
    property var states: ({})
    property var failures: ({})
    property var pending: []
    property string busy: ""
    property string copied: ""

    function target(entry): string {
        return entry.kind === ServiceKind.flag ? `${root.flagDir}/${entry.unit}` : entry.unit;
    }

    function active(id: string): bool {
        return root.states[id]?.ActiveState === "active";
    }

    function installed(id: string): bool {
        return root.states[id]?.LoadState !== "not-found";
    }

    function verb(entry, on: bool): var {
        if (root.states[entry.id]?.UnitFileState === "static")
            return on ? Commands.serviceStart : Commands.serviceStop;
        return on ? Commands.serviceOn : Commands.serviceOff;
    }

    function tilde(path: string): string {
        return path.startsWith(Paths.home) ? `~${path.slice(Paths.home.length)}` : path;
    }

    function commands(entry): var {
        const unit = root.tilde(root.target(entry));
        if (entry.kind === ServiceKind.flag)
            return {
                enable: Commands.serviceFlagEnable.arg(unit),
                kill: Commands.serviceFlagKill.arg(unit),
                install: ""
            };
        const template = entry.kind === ServiceKind.user ? Commands.serviceUser : Commands.serviceSystem;
        return {
            enable: template.arg(root.verb(entry, true).join(" ")).arg(unit),
            kill: template.arg(root.verb(entry, false).join(" ")).arg(unit),
            install: entry.installable ? Commands.serviceSystemInstall.arg(root.tilde(Quickshell.shellDir)).arg(unit.replace(/\.service$/, "")).arg(unit) : ""
        };
    }

    function argv(entry, on: bool): var {
        const unit = root.target(entry);
        if (entry.kind === ServiceKind.flag)
            return on ? ["rm", "-f", unit] : ["sh", "-c", Commands.serviceFlagOff, "sh", unit];
        const scope = entry.kind === ServiceKind.user ? ["systemctl", "--user"] : ["systemctl"];
        return scope.concat(root.verb(entry, on), [unit]);
    }

    function set(entry, on: bool): void {
        root.run(entry.id, root.argv(entry, on));
    }

    function install(entry): void {
        root.run(entry.id, ["pkexec", "sh", "-c", Commands.serviceInstall, "sh", Quickshell.shellDir, entry.unit]);
    }

    function run(id: string, command: var): void {
        root.pending = root.pending.concat([
            {
                id,
                command
            }
        ]);
        root.drain();
    }

    function drain(): void {
        if (runner.running || root.pending.length === 0)
            return;
        const job = root.pending[0];
        root.pending = root.pending.slice(1);
        root.busy = job.id;
        runner.command = job.command;
        runner.running = true;
    }

    function finish(code: int): void {
        const next = Object.assign({}, root.failures);
        if (code === 0)
            delete next[root.busy];
        else
            next[root.busy] = code;
        root.failures = next;
        root.busy = "";
        root.refresh();
        root.drain();
    }

    function adopt(text: string): void {
        const next = {};
        for (const line of text.split("\n")) {
            const tab = line.indexOf("\t");
            if (tab <= 0)
                continue;
            const fields = {};
            for (const pair of line.slice(tab + 1).trim().split(" ")) {
                const equals = pair.indexOf("=");
                if (equals > 0)
                    fields[pair.slice(0, equals)] = pair.slice(equals + 1);
            }
            next[line.slice(0, tab)] = fields;
        }
        root.states = next;
    }

    function refresh(): void {
        status.running = true;
    }

    function copy(text: string): void {
        Quickshell.execDetached(["wl-copy", "--", text]);
        root.copied = text;
        copiedTimer.restart();
    }

    Process {
        id: runner

        onExited: code => root.finish(code)
    }

    Process {
        id: status

        command: ["sh", "-c", Commands.serviceStatus, "sh"].concat(root.specs)

        stdout: StdioCollector {
            onStreamFinished: root.adopt(text)
        }
    }

    Timer {
        interval: root.config.pollInterval
        running: root.polling
        repeat: true
        triggeredOnStart: true

        onTriggered: root.refresh()
    }

    Timer {
        id: copiedTimer

        interval: root.config.copiedTimeout

        onTriggered: root.copied = ""
    }
}
