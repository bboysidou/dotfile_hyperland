import QtQuick
import qs.core.config
import qs.core.enums
import qs.core.helpers
import qs.modules.screenshot

MouseArea {
    id: root

    required property real zoom
    required property real originX
    required property real originY

    property var origin: null
    property var grip: null
    property bool moving: false
    property real startX: 0
    property real startY: 0

    function at(mouse): var {
        return {
            x: mouse.x / root.zoom + root.originX,
            y: mouse.y / root.zoom + root.originY
        };
    }

    function inside(p): var {
        return {
            x: Math.max(0, Math.min(p.x, EditorState.imageWidth)),
            y: Math.max(0, Math.min(p.y, EditorState.imageHeight))
        };
    }

    function framed(tool: string, p): var {
        const frame = {
            kind: tool,
            x1: p.x,
            y1: p.y,
            x2: p.x,
            y2: p.y
        };
        if (tool === EditTool.crop)
            return frame;
        if (tool === EditTool.redact)
            return Object.assign(frame, {
                style: EditorState.redactStyle
            });
        return Object.assign(frame, {
            style: EditorState.arrowStyle,
            color: String(EditorState.colour),
            width: EditorState.strokeWidth,
            filled: EditorState.filled
        });
    }

    function begin(p): void {
        const tool = EditorState.tool;
        const colour = String(EditorState.colour);
        const width = EditorState.strokeWidth;
        if (tool === EditTool.marker) {
            EditorState.add({
                kind: tool,
                x1: p.x,
                y1: p.y,
                radius: (Appearance.editor.markerBase + width * Appearance.editor.markerPerWidth) / 2,
                number: EditorState.nextMarker(),
                color: colour,
                width: width
            });
        } else if (tool === EditTool.text) {
            EditorState.editText(EditorState.add({
                kind: tool,
                x1: p.x,
                y1: p.y,
                text: "",
                size: Appearance.editor.textBase + width * Appearance.editor.textPerWidth,
                color: colour,
                width: width
            }));
        } else if (tool === EditTool.highlight) {
            EditorState.draft = {
                kind: tool,
                points: [p],
                color: Appearance.editor.palette[Appearance.editor.highlightColor],
                width: Appearance.editor.highlightWidth,
                opacity: Appearance.editor.highlightOpacity
            };
        } else {
            EditorState.draft = root.framed(tool, tool === EditTool.crop ? root.inside(p) : p);
        }
    }

    function extend(p, constrain: bool): void {
        const draft = EditorState.draft;
        if (draft.points) {
            const last = draft.points[draft.points.length - 1];
            if (Math.hypot(p.x - last.x, p.y - last.y) * root.zoom >= Appearance.editor.minDrag)
                EditorState.draft = Object.assign({}, draft, {
                    points: [...draft.points, p]
                });
            return;
        }
        const free = draft.kind === EditTool.crop ? root.inside(p) : p;
        const end = constrain ? Ink.constrained(draft, free.x, free.y) : free;
        EditorState.draft = Object.assign({}, draft, {
            x2: end.x,
            y2: end.y
        });
    }

    function commit(): void {
        const draft = EditorState.draft;
        EditorState.draft = null;
        if (!draft)
            return;

        const box = Ink.box(draft);
        if (draft.kind === EditTool.crop) {
            if (Math.min(box.width, box.height) >= Appearance.editor.minCrop) {
                EditorState.setCrop(box);
                EditorState.setTool(EditTool.select);
            }
            return;
        }
        const size = draft.points ? draft.points.length > 1 : Math.max(box.width, box.height) * root.zoom >= Appearance.editor.minDrag;
        if (size)
            EditorState.add(draft);
    }

    hoverEnabled: true
    cursorShape: EditorState.tool === EditTool.select ? Qt.ArrowCursor : EditorState.tool === EditTool.text ? Qt.IBeamCursor : Qt.CrossCursor

    onPressed: mouse => {
        const p = root.at(mouse);
        if (EditorState.editing >= 0) {
            EditorState.finishText();
            return;
        }
        if (EditorState.tool !== EditTool.select) {
            root.begin(p);
            return;
        }
        const tolerance = Appearance.editor.hitTolerance / root.zoom;
        const current = EditorState.items[EditorState.selected] ?? null;
        root.grip = current ? Ink.handleAt(current, p.x, p.y, tolerance) : null;
        const index = root.grip ? EditorState.selected : Ink.topHit(EditorState.items, p.x, p.y, tolerance);
        EditorState.selected = index;
        root.origin = index >= 0 ? EditorState.items[index] : null;
        root.startX = p.x;
        root.startY = p.y;
        root.moving = false;
    }

    onPositionChanged: mouse => {
        const p = root.at(mouse);
        if (EditorState.draft)
            root.extend(p, mouse.modifiers & Qt.ShiftModifier);
        else if (root.pressed && root.origin && EditorState.selected >= 0) {
            const next = root.grip ? Ink.gripped(root.origin, root.grip, p.x, p.y) : Ink.moved(root.origin, p.x - root.startX, p.y - root.startY);
            EditorState.replace(EditorState.selected, next, !root.moving);
            root.moving = true;
        }
    }

    onReleased: {
        root.commit();
        root.origin = null;
        root.grip = null;
    }

    onDoubleClicked: mouse => {
        const p = root.at(mouse);
        const index = Ink.topHit(EditorState.items, p.x, p.y, Appearance.editor.hitTolerance / root.zoom);
        if (index >= 0 && EditorState.items[index].kind === EditTool.text)
            EditorState.editText(index);
    }
}
