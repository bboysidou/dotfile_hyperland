pragma Singleton

import QtQuick
import Quickshell
import qs.core.config
import qs.core.enums
import qs.core.helpers
import qs.services

Singleton {
    id: root

    property bool opened: false
    property string path: ""
    property string screen: ""
    property int imageWidth: 0
    property int imageHeight: 0
    property string tool: EditTool.arrow
    property string arrowStyle: ArrowStyle.standard
    property string redactStyle: RedactStyle.pixelate
    property bool filled: false
    property var crop: null
    property int backdrop: -1
    property int colorIndex: Appearance.editor.defaultColor
    property int widthIndex: Appearance.editor.defaultWidth
    property var items: []
    property var draft: null
    property int selected: -1
    property int editing: -1
    property string draftText: ""
    property var undoStack: []
    property var redoStack: []
    property int serial: 0

    readonly property color colour: Appearance.editor.palette[root.colorIndex]
    readonly property real strokeWidth: Appearance.editor.widths[root.widthIndex]
    readonly property var styled: [EditTool.arrow, EditTool.line, EditTool.rect, EditTool.ellipse, EditTool.marker, EditTool.text]
    readonly property var full: ({
            x: 0,
            y: 0,
            width: root.imageWidth,
            height: root.imageHeight
        })
    readonly property var view: root.crop ?? root.full
    readonly property int pad: root.backdrop >= 0 ? Math.round(Math.max(root.view.width, root.view.height) * Appearance.editor.backdropRatio) : 0

    signal exportRequested(string output)

    function open(path: string): void {
        if (Lock.locked || !path)
            return;

        root.reset();
        root.screen = Monitors.focused;
        root.opened = true;
        root.path = path;
    }

    function close(): void {
        root.opened = false;
        root.path = "";
        root.reset();
    }

    function reset(): void {
        root.items = [];
        root.crop = null;
        root.draft = null;
        root.selected = -1;
        root.editing = -1;
        root.undoStack = [];
        root.redoStack = [];
        root.imageWidth = 0;
        root.imageHeight = 0;
    }

    function setTool(tool: string): void {
        root.finishText();
        if (tool === root.tool && tool === EditTool.arrow)
            root.arrowStyle = root.cycle(ArrowStyle.values, root.arrowStyle);
        else if (tool === root.tool && tool === EditTool.redact)
            root.redactStyle = root.cycle(RedactStyle.values, root.redactStyle);
        else if (tool === root.tool && tool === EditTool.crop)
            root.setCrop(null);
        root.tool = tool;
        root.selected = -1;
    }

    function setColor(index: int): void {
        root.colorIndex = Math.max(0, Math.min(index, Appearance.editor.palette.length - 1));
        root.restyle(root.styled, {
            color: String(root.colour)
        });
    }

    function stepWidth(delta: int): void {
        root.widthIndex = Math.max(0, Math.min(root.widthIndex + delta, Appearance.editor.widths.length - 1));
        root.restyle(root.styled, {
            width: root.strokeWidth
        });
    }

    function toggleFill(): void {
        root.filled = !root.filled;
        root.restyle([EditTool.rect, EditTool.ellipse], {
            filled: root.filled
        });
    }

    function cycleBackdrop(): void {
        root.backdrop = (root.backdrop + 2) % (Appearance.editor.backdrops.length + 1) - 1;
    }

    function cycle(values, current: string): string {
        return values[(values.indexOf(current) + 1) % values.length];
    }

    function restyle(kinds, change): void {
        if (root.selected < 0 || !kinds.includes(root.items[root.selected].kind))
            return;

        root.replace(root.selected, Object.assign({}, root.items[root.selected], change), true);
    }

    function setCrop(box): void {
        if (!box && !root.crop)
            return;

        root.snapshot();
        if (!box) {
            root.crop = null;
            return;
        }
        const x = Math.max(0, Math.round(box.x));
        const y = Math.max(0, Math.round(box.y));
        root.crop = {
            x: x,
            y: y,
            width: Math.min(root.imageWidth, Math.round(box.x + box.width)) - x,
            height: Math.min(root.imageHeight, Math.round(box.y + box.height)) - y
        };
    }

    function state(): string {
        return JSON.stringify({
            items: root.items,
            crop: root.crop
        });
    }

    function restore(saved: string): void {
        const parsed = JSON.parse(saved);
        root.items = parsed.items;
        root.crop = parsed.crop;
        root.selected = -1;
    }

    function snapshot(): void {
        root.undoStack = [...root.undoStack, root.state()];
        root.redoStack = [];
    }

    function add(item): int {
        root.snapshot();
        root.items = [...root.items, item];
        return root.items.length - 1;
    }

    function replace(index: int, item, record: bool): void {
        if (record)
            root.snapshot();

        const copy = root.items.slice();
        copy[index] = item;
        root.items = copy;
    }

    function remove(index: int): void {
        if (index < 0 || index >= root.items.length)
            return;

        root.snapshot();
        root.items = root.items.filter((_, i) => i !== index);
        root.selected = -1;
    }

    function undo(): void {
        root.finishText();
        if (!root.undoStack.length)
            return;

        root.redoStack = [...root.redoStack, root.state()];
        root.restore(root.undoStack[root.undoStack.length - 1]);
        root.undoStack = root.undoStack.slice(0, -1);
    }

    function redo(): void {
        root.finishText();
        if (!root.redoStack.length)
            return;

        root.undoStack = [...root.undoStack, root.state()];
        root.restore(root.redoStack[root.redoStack.length - 1]);
        root.redoStack = root.redoStack.slice(0, -1);
    }

    function nextMarker(): int {
        return root.items.filter(a => a.kind === EditTool.marker).reduce((top, a) => Math.max(top, a.number), 0) + 1;
    }

    function measure(index: int, width: real, height: real): void {
        const item = root.items[index];
        if (item) {
            item.measuredWidth = width;
            item.measuredHeight = height;
        }
    }

    function editText(index: int): void {
        root.draftText = root.items[index]?.text ?? "";
        root.editing = index;
    }

    function finishText(): void {
        const index = root.editing;
        if (index < 0)
            return;

        root.editing = -1;
        if (root.draftText.trim()) {
            root.replace(index, Object.assign({}, root.items[index], {
                text: root.draftText
            }), false);
            return;
        }
        root.items = root.items.filter((_, i) => i !== index);
        root.undoStack = root.undoStack.slice(0, -1);
    }

    Connections {
        target: Lock

        function onLockedChanged(): void {
            if (Lock.locked)
                root.close();
        }
    }
}
