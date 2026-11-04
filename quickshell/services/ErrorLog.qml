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

    readonly property var config: Appearance.errorLog
    readonly property string stateDir: `${Paths.state}/${Appearance.state.dir}`
    readonly property string statePath: `${root.stateDir}/${root.config.stateFile}`
    readonly property string crashDir: `${Paths.cache}/${root.config.crashDir}`
    readonly property string shellPrefix: `${Quickshell.shellDir}/`

    property bool loaded: false
    property real clearedAt: 0
    property real seenAt: Date.now()
    property var entries: []
    property int errorCount: 0
    property int warnCount: 0
    property int unseen: 0
    property bool copied: false

    property var groups: ({})
    property var order: []
    property var pending: null

    function report(source: string, message: string): void {
        root.commit();
        root.add({
            level: LogLevel.report,
            source,
            message,
            details: "",
            time: Date.now()
        });
    }

    function markSeen(): void {
        root.seenAt = Date.now();
        root.unseen = 0;
    }

    function clear(): void {
        root.clearedAt = Date.now();
        root.groups = {};
        root.order = [];
        root.pending = null;
        root.publish();
        store.setText(JSON.stringify({
            clearedAt: root.clearedAt
        }));
    }

    function locate(message: string): var {
        const match = LogFormat.qmlLocation.exec(message);
        if (!match)
            return null;
        const file = match[1].startsWith(root.shellPrefix) ? match[1].slice(root.shellPrefix.length) : match[1];
        return {
            source: LogFormat.locationTemplate.arg(file).arg(match[2]),
            message: match[3]
        };
    }

    function extend(text: string): void {
        root.pending.details += (root.pending.details ? "\n" : "") + text;
    }

    function ingest(line: string): void {
        const match = LogFormat.line.exec(line);
        if (!match) {
            if (root.pending && line.length > 0)
                root.extend(line);
            return;
        }
        const level = LogLevel.fromToken[match[3]];
        const message = match[5];
        if (level && root.pending && LogFormat.continuation.test(message)) {
            root.extend(message.trim());
            return;
        }
        root.commit();
        const time = Date.parse(`${match[1]}${LogFormat.timeSeparator}${match[2]}`);
        if (!level || time <= root.clearedAt)
            return;
        const located = root.locate(message);
        root.pending = {
            level,
            source: located?.source ?? match[4] ?? "",
            message: located?.message ?? message,
            details: "",
            time
        };
        publisher.restart();
    }

    function commit(): void {
        if (!root.pending)
            return;
        const item = root.pending;
        root.pending = null;
        root.add(item);
    }

    function add(item: var): void {
        const key = item.groupKey ?? [item.level, item.source, item.message, item.details].join("|").replace(LogFormat.address, "0x");
        const existing = root.groups[key];
        if (existing) {
            existing.count += 1;
            existing.time = Math.max(existing.time, item.time);
        } else {
            const entry = Object.assign({
                key,
                count: 1
            }, item);
            root.groups[key] = entry;
            root.order.push(entry);
            root.trim();
        }
        publisher.restart();
    }

    function trim(): void {
        if (root.order.length <= root.config.maxEntries)
            return;
        root.order.sort((a, b) => a.time - b.time);
        for (const dropped of root.order.splice(0, root.order.length - root.config.maxEntries))
            delete root.groups[dropped.key];
    }

    function publish(): void {
        root.commit();
        const next = root.order.slice().sort((a, b) => b.time - a.time).map(entry => Object.assign({}, entry));
        root.entries = next;
        root.errorCount = next.filter(entry => LogLevel.isError(entry.level)).length;
        root.warnCount = next.length - root.errorCount;
        root.unseen = next.filter(entry => LogLevel.isError(entry.level) && entry.time > root.seenAt).length;
    }

    function resetLog(): void {
        root.pending = null;
        root.retain(entry => entry.level === LogLevel.crash || entry.level === LogLevel.report || entry.source === root.config.hyprlandSource);
    }

    function retain(keep: var): void {
        root.order = root.order.filter(keep);
        const next = {};
        for (const entry of root.order)
            next[entry.key] = entry;
        root.groups = next;
    }

    function adoptCrashes(text: string): void {
        for (const line of text.split("\n")) {
            const fields = line.split(LogFormat.fieldSeparator);
            const time = Number(fields[0]) * Units.msPerSecond;
            if (fields.length < 3 || !(time > root.clearedAt))
                continue;
            root.add({
                level: LogLevel.crash,
                source: root.config.crashSource,
                message: fields[2] || root.config.crashFallback,
                details: fields[1],
                time
            });
        }
    }

    function format(entry: var): string {
        const stamp = Qt.formatDateTime(new Date(entry.time), root.config.timeFormat);
        const head = root.config.copyLineTemplate.arg(stamp).arg(LogLevel.labels[entry.level]).arg(entry.source).arg(entry.message);
        const count = entry.count > 1 ? root.config.copyCountTemplate.arg(entry.count) : "";
        return `${head}${count}${entry.details ? `\n${entry.details}` : ""}`;
    }

    function copy(entry: var): void {
        if (entry.level === LogLevel.crash)
            Quickshell.execDetached(["sh", "-c", Commands.copyFile, "sh", entry.details]);
        else
            Quickshell.execDetached(["wl-copy", "--", root.format(entry)]);
    }

    function copyAll(list: var): void {
        Quickshell.execDetached(["wl-copy", "--", list.map(entry => root.format(entry)).join("\n\n")]);
        root.copied = true;
        copiedTimer.restart();
    }

    Timer {
        id: publisher

        interval: root.config.publishDelay

        onTriggered: root.publish()
    }

    Timer {
        id: copiedTimer

        interval: root.config.copiedTimeout

        onTriggered: root.copied = false
    }

    Timer {
        id: restarter

        interval: root.config.restartDelay

        onTriggered: follower.running = true
    }

    Process {
        id: follower

        running: root.loaded
        command: Commands.logFollow.concat([String(Quickshell.processId)])

        stdout: SplitParser {
            onRead: line => root.ingest(line)
        }

        onStarted: root.resetLog()
        onExited: restarter.restart()
    }

    HyprlandLogFeed {
        active: root.loaded

        onCaptured: item => {
            if (item.time > root.clearedAt)
                root.add(item);
        }
        onRestarted: root.retain(entry => entry.source !== root.config.hyprlandSource)
    }

    Process {
        running: root.loaded
        command: ["sh", "-c", Commands.crashReports, "sh", root.crashDir]

        stdout: StdioCollector {
            onStreamFinished: root.adoptCrashes(text)
        }
    }

    FileView {
        id: store

        path: root.statePath
        atomicWrites: true
        printErrors: false

        onLoaded: {
            if (root.loaded)
                return;
            try {
                root.clearedAt = JSON.parse(text()).clearedAt ?? 0;
            } catch (parseError) {}
            root.loaded = true;
        }
        onLoadFailed: root.loaded = true
    }
}
