import QtQuick
import qs.core.config
import qs.core.enums
import qs.core.helpers
import qs.modules.screenshot

Item {
    id: root

    required property real zoom

    readonly property var box: EditorState.draft?.kind === EditTool.crop ? Ink.box(EditorState.draft) : EditorState.crop
    readonly property var hole: root.box ? Qt.rect(root.box.x * root.zoom, root.box.y * root.zoom, root.box.width * root.zoom, root.box.height * root.zoom) : null

    ScreenshotDim {
        anchors.fill: parent

        visible: root.hole !== null
        hole: root.hole
    }

    Rectangle {
        x: root.hole?.x ?? 0
        y: root.hole?.y ?? 0
        width: root.hole?.width ?? 0
        height: root.hole?.height ?? 0

        visible: root.hole !== null
        color: "transparent"
        border.color: Colours.accent
        border.width: Appearance.screenshot.borderWidth
    }
}
