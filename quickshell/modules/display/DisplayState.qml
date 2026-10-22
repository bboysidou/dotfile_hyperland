pragma Singleton

import QtQuick
import Quickshell
import qs.core.config
import qs.core.helpers
import qs.services

Singleton {
    id: root

    property bool opened: false
    property string monitor: ""
    property string tab: Appearance.display.tabMode
    property var drafts: ({})
    property var assignment: []
    property bool bezels: false

    readonly property var config: Appearance.display
    readonly property var current: Displays.find(root.monitor)
    readonly property var draft: root.drafts[root.monitor] ?? null
    readonly property var modes: root.current?.modes ?? []
    readonly property int modeIndex: root.draft ? root.modes.findIndex(mode => mode.width === root.draft.width && mode.height === root.draft.height) : -1
    readonly property var rates: root.modes[root.modeIndex]?.rates ?? []
    readonly property int rateIndex: root.draft ? root.rates.indexOf(root.draft.rate) : -1
    readonly property var names: Displays.monitors.map(entry => entry.name)
    readonly property int enabledCount: root.names.filter(name => !(root.drafts[name]?.disabled ?? true)).length
    readonly property bool changed: JSON.stringify(root.drafts) !== JSON.stringify(Displays.snapshot().settings) || JSON.stringify(root.assignment) !== JSON.stringify(Displays.workspaces)

    function show(): void {
        Displays.refresh();
        root.opened = true;
    }

    function hide(): void {
        Displays.revert();
        root.opened = false;
    }

    function toggle(): void {
        if (root.opened)
            root.hide();
        else
            root.show();
    }

    function reset(): void {
        const drafts = {};
        for (const entry of Displays.monitors)
            drafts[entry.name] = Object.assign({}, entry.settings);
        root.drafts = drafts;
        root.assignment = Displays.workspaces.slice();
        if (!Displays.find(root.monitor))
            root.monitor = Displays.monitors.find(entry => entry.name === Monitors.focused)?.name ?? Displays.monitors[0]?.name ?? "";
    }

    function set(key: string, value): void {
        if (!root.draft)
            return;
        const next = Object.assign({}, root.drafts);
        next[root.monitor] = Object.assign({}, root.draft, {
            [key]: value
        });
        root.drafts = next;
    }

    function selectMode(index: int): void {
        const mode = root.modes[index];
        if (!mode || !root.draft)
            return;
        root.set("width", mode.width);
        root.set("height", mode.height);
        root.set("rate", mode.rates.includes(root.draft.rate) ? root.draft.rate : mode.rates[mode.rates.length - 1]);
        root.set("scale", root.scales(mode.width, mode.height).includes(root.draft.scale) ? root.draft.scale : 1);
    }

    function stepMode(delta: int): void {
        if (root.modes.length > 0)
            root.selectMode(Num.clamp(root.modeIndex + delta, 0, root.modes.length - 1));
    }

    function selectRate(index: int): void {
        if (index >= 0 && index < root.rates.length)
            root.set("rate", root.rates[index]);
    }

    function stepRate(delta: int): void {
        root.selectRate(Num.clamp(root.rateIndex + delta, 0, root.rates.length - 1));
    }

    function scales(width: int, height: int): var {
        const tolerance = root.config.scaleTolerance;
        const whole = value => Math.abs(value - Math.round(value)) < tolerance;
        return root.config.scales.filter(scale => whole(width / scale) && whole(height / scale));
    }

    function logical(settings): var {
        const rotated = settings.transform % 2 === 1;
        return {
            width: Math.round((rotated ? settings.height : settings.width) / settings.scale),
            height: Math.round((rotated ? settings.width : settings.height) / settings.scale)
        };
    }

    function placed(name: string): bool {
        const settings = root.drafts[name];
        return settings && !settings.disabled && !settings.mirror;
    }

    function overlaps(name: string, x: int, y: int): bool {
        const size = root.logical(root.drafts[name]);
        return root.names.some(other => {
            if (other === name || !root.placed(other))
                return false;
            const box = root.drafts[other];
            const otherSize = root.logical(box);
            return x < box.x + otherSize.width && x + size.width > box.x && y < box.y + otherSize.height && y + size.height > box.y;
        });
    }

    function snap(value: int, candidates): int {
        let best = value;
        let distance = root.config.snapDistance;
        for (const candidate of candidates) {
            if (Math.abs(candidate - value) < distance) {
                distance = Math.abs(candidate - value);
                best = candidate;
            }
        }
        return best;
    }

    function place(name: string, x: int, y: int): void {
        const size = root.logical(root.drafts[name]);
        const xs = [];
        const ys = [];
        for (const other of root.names) {
            if (other === name || !root.placed(other))
                continue;
            const box = root.drafts[other];
            const otherSize = root.logical(box);
            xs.push(box.x - size.width, box.x + otherSize.width, box.x, box.x + otherSize.width - size.width);
            ys.push(box.y - size.height, box.y + otherSize.height, box.y, box.y + otherSize.height - size.height);
        }
        const snappedX = root.snap(x, xs);
        const snappedY = root.snap(y, ys);
        if (root.overlaps(name, snappedX, snappedY)) {
            root.drafts = Object.assign({}, root.drafts);
            return;
        }
        const previous = root.monitor;
        root.monitor = name;
        root.set("x", snappedX);
        root.set("y", snappedY);
        root.monitor = previous;
        root.normalise();
    }

    function nudge(axis: string, delta: int): void {
        if (!root.draft)
            return;
        const x = root.draft.x + (axis === "x" ? delta : 0);
        const y = root.draft.y + (axis === "y" ? delta : 0);
        if (!root.overlaps(root.monitor, x, y)) {
            root.set("x", x);
            root.set("y", y);
            root.normalise();
        }
    }

    function normalise(): void {
        const placed = root.names.filter(name => root.placed(name));
        if (placed.length === 0)
            return;
        const minX = Math.min(...placed.map(name => root.drafts[name].x));
        const minY = Math.min(...placed.map(name => root.drafts[name].y));
        if (minX === 0 && minY === 0)
            return;
        const next = Object.assign({}, root.drafts);
        for (const name of placed)
            next[name] = Object.assign({}, next[name], {
                x: next[name].x - minX,
                y: next[name].y - minY
            });
        root.drafts = next;
    }

    function setActive(on: bool): void {
        if (!on && root.enabledCount <= 1)
            return;
        root.set("disabled", !on);
    }

    function assign(workspace: int): void {
        const next = root.assignment.slice();
        next[workspace - 1] = root.monitor;
        root.assignment = next;
    }

    function apply(): void {
        if (root.changed && root.enabledCount > 0)
            Displays.commit(root.drafts, root.assignment);
    }

    Connections {
        target: Displays

        function onMonitorsChanged(): void {
            if (!Displays.confirming)
                root.reset();
        }

        function onWorkspacesChanged(): void {
            if (!Displays.confirming)
                root.assignment = Displays.workspaces.slice();
        }
    }
}
