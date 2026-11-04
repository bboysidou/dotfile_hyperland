import QtQuick
import Quickshell
import Quickshell.Io
import qs.core.config
import qs.core.constants
import qs.core.enums

Scope {
    id: root

    property bool active: false

    readonly property var config: Appearance.errorLog
    readonly property string signature: Quickshell.env("HYPRLAND_INSTANCE_SIGNATURE") ?? ""
    readonly property string logPath: root.config.hyprlandLogTemplate.arg(Quickshell.env("XDG_RUNTIME_DIR") ?? "").arg(root.signature)
    readonly property real startedAt: Number(root.signature.split("_")[1] ?? 0) * Units.msPerSecond

    property string version: ""
    property var context: []

    signal captured(var item)
    signal restarted

    function timeOf(clock: string, rolls: int): real {
        if (!clock)
            return root.startedAt;
        const parts = clock.split(":").map(Number);
        const date = new Date(root.startedAt);
        date.setHours(parts[0], parts[1], parts[2], 0);
        date.setDate(date.getDate() + rolls);
        return date.getTime() < root.startedAt ? date.getTime() + Units.msPerDay : date.getTime();
    }

    function describe(origin: string, call: string, stamp: string, number: string): string {
        const lines = [root.config.hyprlandOriginTemplate.arg(origin || root.config.hyprlandCoreLabel)];
        if (call)
            lines.push(root.config.hyprlandCallTemplate.arg(call));
        lines.push(root.config.hyprlandStampTemplate.arg(stamp || root.config.hyprlandNoStamp));
        lines.push(root.config.hyprlandVersionTemplate.arg(root.version));
        lines.push(root.config.hyprlandSessionTemplate.arg(root.signature));
        lines.push(root.config.hyprlandFileTemplate.arg(root.logPath).arg(number));
        if (root.context.length > 0)
            lines.push("", root.config.hyprlandContextTemplate.arg(root.context.length), ...root.context);
        return lines.join("\n");
    }

    function capture(fields: var): void {
        const match = LogFormat.hyprland.exec(fields.slice(4).join(LogFormat.fieldSeparator));
        const level = match ? LogLevel.fromToken[match[1]] : null;
        if (level) {
            const message = match[5];
            const key = [level, root.config.hyprlandSource, match[3] ?? "", match[4] ?? "", message].join("|");
            root.captured({
                level,
                source: root.config.hyprlandSource,
                message,
                details: root.describe(match[3] ?? "", match[4] ?? "", match[2] ?? "", fields[1]),
                time: root.timeOf(fields[2], Number(fields[3])),
                groupKey: key.replace(LogFormat.address, "0x").replace(LogFormat.number, "#")
            });
        }
        root.context = [];
    }

    function ingest(line: string): void {
        const fields = line.split(LogFormat.fieldSeparator);
        if (fields[0] === root.config.hyprlandVersionMark)
            root.version = fields[1] ?? "";
        else if (fields[0] === root.config.hyprlandContextMark)
            root.context = root.context.concat([fields.slice(1).join(LogFormat.fieldSeparator)]);
        else if (fields[0] === root.config.hyprlandEntryMark)
            root.capture(fields);
    }

    Timer {
        id: restarter

        interval: root.config.restartDelay

        onTriggered: follower.running = true
    }

    Process {
        id: follower

        running: root.active && root.signature !== ""
        command: ["sh", "-c", Commands.hyprlandErrors, "sh", String(Quickshell.processId), root.logPath, String(root.config.hyprlandContextLines)]

        stdout: SplitParser {
            onRead: line => root.ingest(line)
        }

        onStarted: {
            root.context = [];
            root.restarted();
        }
        onExited: restarter.restart()
    }
}
