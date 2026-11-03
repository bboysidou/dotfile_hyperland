pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config
import qs.core.enums
import qs.modules.screenshot

StyledRect {
    id: root

    readonly property var tools: [
        {
            tool: EditTool.select,
            icon: Icons.editSelect
        },
        {
            tool: EditTool.arrow,
            icon: Icons.editArrow
        },
        {
            tool: EditTool.line,
            icon: Icons.editLine
        },
        {
            tool: EditTool.rect,
            icon: Icons.editRect
        },
        {
            tool: EditTool.ellipse,
            icon: Icons.editEllipse
        },
        {
            tool: EditTool.marker,
            icon: Icons.editMarker
        },
        {
            tool: EditTool.text,
            icon: Icons.editText
        },
        {
            tool: EditTool.highlight,
            icon: Icons.editHighlight
        },
        {
            tool: EditTool.redact,
            icon: Icons.editRedact
        },
        {
            tool: EditTool.crop,
            icon: Icons.editCrop
        }
    ]
    readonly property var actions: [
        {
            action: EditAction.fill,
            icon: Icons.editFill
        },
        {
            action: EditAction.backdrop,
            icon: Icons.editBackdrop
        },
        {
            action: EditAction.undo,
            icon: Icons.editUndo
        },
        {
            action: EditAction.redo,
            icon: Icons.editRedo
        },
        {
            action: EditAction.pin,
            icon: Icons.pin
        },
        {
            action: EditAction.ocr,
            icon: Icons.editOcr
        },
        {
            action: EditAction.copy,
            icon: Icons.editCopy
        },
        {
            action: EditAction.save,
            icon: Icons.editSave
        },
        {
            action: EditAction.close,
            icon: Icons.editClose
        }
    ]

    function run(action: string): void {
        if (action === EditAction.fill)
            EditorState.toggleFill();
        else if (action === EditAction.backdrop)
            EditorState.cycleBackdrop();
        else if (action === EditAction.undo)
            EditorState.undo();
        else if (action === EditAction.redo)
            EditorState.redo();
        else if (action === EditAction.pin)
            EditorState.exportRequested(EditOutput.pin);
        else if (action === EditAction.ocr)
            EditorState.exportRequested(EditOutput.ocr);
        else if (action === EditAction.copy)
            EditorState.exportRequested(EditOutput.copy);
        else if (action === EditAction.save)
            EditorState.exportRequested(EditOutput.both);
        else
            EditorState.close();
    }

    function lit(action: string): bool {
        return action === EditAction.fill && EditorState.filled || action === EditAction.backdrop && EditorState.backdrop >= 0;
    }

    function blocked(action: string): bool {
        return action === EditAction.undo && !EditorState.undoStack.length || action === EditAction.redo && !EditorState.redoStack.length;
    }

    implicitWidth: row.implicitWidth + Appearance.editor.toolbarPadding * 2
    implicitHeight: row.implicitHeight + Appearance.editor.toolbarPadding * 2

    color: Colours.surface
    radius: Appearance.editor.toolbarRounding
    border.width: Appearance.editor.buttonBorder
    border.color: Colours.border

    RowLayout {
        id: row

        anchors.centerIn: parent

        spacing: Appearance.editor.toolbarSpacing

        Repeater {
            model: root.tools

            EditorButton {
                required property var modelData

                icon: modelData.icon
                label: EditTool.labels[modelData.tool]
                hint: EditTool.hints[modelData.tool]
                active: EditorState.tool === modelData.tool

                onTriggered: EditorState.setTool(modelData.tool)
            }
        }

        EditorDivider {}

        Repeater {
            model: Appearance.editor.palette

            EditorSwatch {
                required property var modelData
                required property int index

                swatch: modelData
                active: EditorState.colorIndex === index

                onPicked: EditorState.setColor(index)
            }
        }

        EditorDivider {}

        Repeater {
            model: root.actions

            EditorButton {
                required property var modelData

                icon: modelData.icon
                label: EditAction.labels[modelData.action]
                hint: EditAction.hints[modelData.action]
                active: root.lit(modelData.action)
                disabled: root.blocked(modelData.action)

                onTriggered: root.run(modelData.action)
            }
        }
    }
}
