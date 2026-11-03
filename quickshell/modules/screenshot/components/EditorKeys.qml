import QtQuick
import qs.core.config
import qs.core.enums
import qs.core.helpers
import qs.modules.screenshot

Item {
    id: root

    readonly property var toolKeys: ({
            [Qt.Key_V]: EditTool.select,
            [Qt.Key_A]: EditTool.arrow,
            [Qt.Key_L]: EditTool.line,
            [Qt.Key_R]: EditTool.rect,
            [Qt.Key_E]: EditTool.ellipse,
            [Qt.Key_C]: EditTool.marker,
            [Qt.Key_T]: EditTool.text,
            [Qt.Key_H]: EditTool.highlight,
            [Qt.Key_B]: EditTool.redact,
            [Qt.Key_X]: EditTool.crop
        })

    function nudge(dx: int, dy: int, large: bool): void {
        const index = EditorState.selected;
        if (index < 0)
            return;

        const step = large ? Appearance.editor.nudgeLarge : Appearance.editor.nudge;
        EditorState.replace(index, Ink.moved(EditorState.items[index], dx * step, dy * step), true);
    }

    function control(key: int, shift: bool): bool {
        if (key === Qt.Key_Z && shift || key === Qt.Key_Y)
            EditorState.redo();
        else if (key === Qt.Key_Z)
            EditorState.undo();
        else if (key === Qt.Key_C)
            EditorState.exportRequested(EditOutput.copy);
        else if (key === Qt.Key_S)
            EditorState.exportRequested(EditOutput.save);
        else
            return false;
        return true;
    }

    function plain(event): void {
        const key = event.key;
        const shift = event.modifiers & Qt.ShiftModifier;
        if (key === Qt.Key_Escape && EditorState.selected >= 0)
            EditorState.selected = -1;
        else if (key === Qt.Key_Escape)
            EditorState.close();
        else if (key === Qt.Key_Return || key === Qt.Key_Enter)
            EditorState.exportRequested(EditOutput.both);
        else if (key === Qt.Key_Delete || key === Qt.Key_Backspace)
            EditorState.remove(EditorState.selected);
        else if (key >= Qt.Key_1 && key <= Qt.Key_8)
            EditorState.setColor(key - Qt.Key_1);
        else if (key === Qt.Key_BracketLeft || key === Qt.Key_BracketRight)
            EditorState.stepWidth(key === Qt.Key_BracketLeft ? -1 : 1);
        else if (key === Qt.Key_Left || key === Qt.Key_Right)
            root.nudge(key === Qt.Key_Left ? -1 : 1, 0, shift);
        else if (key === Qt.Key_Up || key === Qt.Key_Down)
            root.nudge(0, key === Qt.Key_Up ? -1 : 1, shift);
        else if (key === Qt.Key_F)
            EditorState.toggleFill();
        else if (key === Qt.Key_G)
            EditorState.cycleBackdrop();
        else if (key === Qt.Key_P)
            EditorState.exportRequested(EditOutput.pin);
        else if (key === Qt.Key_O)
            EditorState.exportRequested(EditOutput.ocr);
        else if (root.toolKeys[key] !== undefined)
            EditorState.setTool(root.toolKeys[key]);
    }

    focus: true

    Keys.onPressed: event => {
        if (event.modifiers & Qt.ControlModifier)
            root.control(event.key, event.modifiers & Qt.ShiftModifier);
        else
            root.plain(event);
        event.accepted = true;
    }
}
