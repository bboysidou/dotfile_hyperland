pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.core.config
import qs.core.constants
import qs.core.helpers

Singleton {
    id: root

    property var monitors: []
    property var workspaces: []
    property var occupied: ({})
    property var saved: ({})
    property var previous: null
    property var pending: null
    property int countdown: 0

    readonly property var config: Appearance.display
    readonly property bool confirming: root.previous !== null

    function refresh(): void {
        monitorsFile.reload();
        workspacesFile.reload();
        query.running = true;
        workspaceQuery.running = true;
    }

    function rate(value: real): string {
        return Number(value).toFixed(root.config.rateDecimals);
    }

    function parseModes(modes): var {
        const groups = {};
        for (const entry of modes ?? []) {
            const match = /^(\d+)x(\d+)@([\d.]+)Hz$/.exec(entry);
            if (!match)
                continue;
            const key = root.config.modeTemplate.arg(match[1]).arg(match[2]);
            groups[key] = groups[key] ?? {
                width: Number(match[1]),
                height: Number(match[2]),
                rates: []
            };
            const value = root.rate(match[3]);
            if (!groups[key].rates.includes(value))
                groups[key].rates.push(value);
        }
        return Object.values(groups).map(group => Object.assign(group, {
                rates: group.rates.sort((first, second) => Number(first) - Number(second))
            })).sort((first, second) => second.width * second.height - first.width * first.height);
    }

    function parseSaved(text: string): void {
        const saved = {};
        for (const line of text.split("\n")) {
            if (!line.trim().startsWith("hl.monitor("))
                continue;
            const fields = {};
            const pattern = /(\w+)\s*=\s*("([^"]*)"|[^,}\s]+)/g;
            let match;
            while ((match = pattern.exec(line)) !== null)
                fields[match[1]] = match[3] !== undefined ? match[3] : match[2];
            if (fields.output)
                saved[fields.output] = fields;
        }
        root.saved = saved;
        query.running = true;
    }

    function parseWorkspaces(text: string): void {
        const list = [];
        const entry = /^\s*"([^"]+)",\s*$/gm;
        const rule = /workspace\s*=\s*"(\d+)",\s*monitor\s*=\s*"([^"]+)"/g;
        let match;
        while ((match = entry.exec(text)) !== null)
            list.push(match[1]);
        if (list.length === 0)
            while ((match = rule.exec(text)) !== null)
                list[Number(match[1]) - 1] = match[2];
        root.workspaces = Array.from({
            length: root.config.workspaceCount
        }, (_, index) => list[index] ?? "");
    }

    function settingsOf(entry): var {
        const saved = root.saved[entry.name] ?? {};
        return {
            width: entry.width,
            height: entry.height,
            rate: root.rate(entry.refreshRate),
            x: entry.x,
            y: entry.y,
            scale: Number(entry.scale),
            transform: entry.transform ?? 0,
            disabled: entry.disabled ?? false,
            mirror: entry.mirrorOf && entry.mirrorOf !== "none" ? entry.mirrorOf : "",
            vrr: saved.vrr !== undefined ? Number(saved.vrr) : (entry.vrr ? 1 : 0),
            bitdepth: (entry.currentFormat ?? "").includes("2101010") ? 10 : 8,
            cm: saved.cm ?? entry.colorManagementPreset ?? root.config.defaultCm,
            sdrbrightness: Number(saved.sdrbrightness ?? entry.sdrBrightness ?? 1),
            sdrsaturation: Number(saved.sdrsaturation ?? entry.sdrSaturation ?? 1),
            dpms: entry.dpmsStatus ?? true
        };
    }

    function receive(payload: string): void {
        let parsed = [];
        try {
            parsed = JSON.parse(payload);
        } catch (error) {
            parsed = [];
        }
        root.monitors = parsed.map(entry => ({
                    name: entry.name,
                    description: entry.description ?? "",
                    focused: entry.focused ?? false,
                    modes: root.parseModes(entry.availableModes),
                    settings: root.settingsOf(entry)
                }));
    }

    function find(name: string): var {
        return root.monitors.find(entry => entry.name === name) ?? null;
    }

    function line(name: string, settings): string {
        if (settings.disabled)
            return `hl.monitor({ output = "${name}", disabled = true })`;

        const fields = [`output = "${name}"`, `mode = "${settings.width}x${settings.height}@${settings.rate}"`, `position = "${settings.x}x${settings.y}"`, `scale = ${settings.scale}`];
        if (settings.transform)
            fields.push(`transform = ${settings.transform}`);
        if (settings.mirror)
            fields.push(`mirror = "${settings.mirror}"`);
        if (settings.bitdepth === 10)
            fields.push("bitdepth = 10");
        if (settings.vrr)
            fields.push(`vrr = ${settings.vrr}`);
        if (settings.cm && settings.cm !== root.config.defaultCm)
            fields.push(`cm = "${settings.cm}"`);
        if (root.config.hdrPresets.includes(settings.cm)) {
            fields.push(`sdrbrightness = ${settings.sdrbrightness}`);
            fields.push(`sdrsaturation = ${settings.sdrsaturation}`);
        }
        return `hl.monitor({ ${fields.join(", ")} })`;
    }

    function rules(assignment): var {
        const seen = {};
        return assignment.map((output, index) => {
            if (!output)
                return "";
            const rule = `hl.workspace_rule({ workspace = "${index + 1}", monitor = "${output}", default = ${!seen[output]} })`;
            seen[output] = true;
            return rule;
        }).filter(rule => rule !== "");
    }

    function moves(assignment): var {
        return assignment.map((output, index) => {
            const current = root.occupied[index + 1];
            if (!output || !current || current === output)
                return "";
            return `hl.dispatch(hl.dsp.workspace.move({ workspace = ${index + 1}, monitor = "${output}" }))`;
        }).filter(move => move !== "");
    }

    function script(state): string {
        const lines = Object.keys(state.settings).map(name => root.line(name, state.settings[name]));
        return lines.concat(root.rules(state.workspaces), root.moves(state.workspaces)).join("\n");
    }

    function snapshot(): var {
        const settings = {};
        for (const monitor of root.monitors)
            settings[monitor.name] = monitor.settings;
        return {
            settings: settings,
            workspaces: root.workspaces.slice()
        };
    }

    function commit(settings, assignment): void {
        if (root.confirming)
            return;

        root.previous = root.snapshot();
        root.pending = {
            settings: settings,
            workspaces: assignment.slice()
        };
        root.countdown = root.config.keepSeconds;
        root.evaluate(root.script(root.pending));
        ticker.restart();
    }

    function keep(): void {
        if (!root.confirming)
            return;

        ticker.stop();
        const monitorLines = Object.keys(root.pending.settings).map(name => root.line(name, root.pending.settings[name]));
        monitorsFile.setText([root.config.monitorsHeader].concat(monitorLines, [root.config.fallbackLine]).join("\n") + "\n");
        workspacesFile.setText(root.config.workspacesTemplate.arg(root.pending.workspaces.map(output => `\t"${output}",`).join("\n")));
        root.workspaces = root.pending.workspaces;
        root.previous = null;
        root.pending = null;
    }

    function revert(): void {
        if (!root.confirming)
            return;

        ticker.stop();
        root.evaluate(root.script(root.previous));
        root.previous = null;
        root.pending = null;
    }

    function setDpms(name: string, on: bool): void {
        root.evaluate(root.config.dpmsTemplate.arg(name).arg(on ? "on" : "off"));
    }

    function evaluate(code: string): void {
        evaluator.command = Commands.hyprEval.concat([code]);
        evaluator.running = true;
    }

    Timer {
        id: ticker

        interval: root.config.tickInterval
        repeat: true

        onTriggered: {
            root.countdown -= 1;
            if (root.countdown <= 0)
                root.revert();
        }
    }

    Process {
        id: evaluator

        onExited: {
            query.running = true;
            workspaceQuery.running = true;
        }
    }

    Process {
        id: query

        command: Commands.monitorsQuery

        stdout: StdioCollector {
            onStreamFinished: root.receive(text)
        }
    }

    Process {
        id: workspaceQuery

        command: Commands.workspacesQuery

        stdout: StdioCollector {
            onStreamFinished: {
                const occupied = {};
                try {
                    for (const entry of JSON.parse(text))
                        occupied[entry.id] = entry.monitor;
                } catch (error) {
                    return;
                }
                root.occupied = occupied;
            }
        }
    }

    FileView {
        id: monitorsFile

        path: Paths.monitors
        printErrors: false

        onLoaded: root.parseSaved(text())
    }

    FileView {
        id: workspacesFile

        path: Paths.workspaces
        printErrors: false

        onLoaded: root.parseWorkspaces(text())
    }
}
