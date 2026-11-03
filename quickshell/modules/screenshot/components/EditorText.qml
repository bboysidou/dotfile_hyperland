import QtQuick
import qs.core.config
import qs.core.helpers
import qs.modules.screenshot

Rectangle {
    id: root

    required property var ann
    required property real zoom
    required property int index
    property bool live: false

    readonly property real size: root.ann.size * root.zoom
    readonly property bool editing: root.live && EditorState.editing === root.index
    readonly property bool light: Ink.luminance(root.ann.color) > Appearance.editor.lightThreshold

    x: root.ann.x1 * root.zoom
    y: root.ann.y1 * root.zoom
    width: Math.max(input.contentWidth, root.size) + root.size * Appearance.editor.textPaddingH * 2
    height: input.contentHeight + root.size * Appearance.editor.textPaddingV * 2
    radius: root.size * Appearance.editor.textRounding

    color: Qt.alpha(root.light ? Colours.shadow : "white", Appearance.editor.pillOpacity)

    onWidthChanged: root.report()
    onHeightChanged: root.report()

    onEditingChanged: {
        if (root.editing)
            input.forceActiveFocus();
    }

    function report(): void {
        if (root.live)
            EditorState.measure(root.index, root.width / root.zoom, root.height / root.zoom);
    }

    TextEdit {
        id: input

        anchors.centerIn: parent

        text: root.ann.text
        readOnly: !root.editing
        color: root.ann.color
        font.family: Appearance.font.family.sans
        font.weight: Font.Bold
        font.pixelSize: root.size
        selectByMouse: root.editing
        cursorVisible: root.editing

        onTextChanged: {
            if (root.editing)
                EditorState.draftText = input.text;
        }

        Keys.onEscapePressed: EditorState.finishText()
        Keys.onPressed: event => {
            if ((event.key === Qt.Key_Return || event.key === Qt.Key_Enter) && !(event.modifiers & Qt.ShiftModifier)) {
                EditorState.finishText();
                event.accepted = true;
            }
        }
    }
}
