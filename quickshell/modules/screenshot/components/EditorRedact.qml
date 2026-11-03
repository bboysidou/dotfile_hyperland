import QtQuick
import qs.core.config
import qs.core.enums
import qs.core.helpers

Item {
    id: root

    required property var ann
    required property real zoom
    required property Item source

    readonly property var box: Ink.box(root.ann)
    readonly property bool solid: root.ann.style === RedactStyle.solid
    readonly property real block: Appearance.editor.pixelBlock

    x: root.box.x * root.zoom
    y: root.box.y * root.zoom
    width: root.box.width * root.zoom
    height: root.box.height * root.zoom
    clip: true

    Rectangle {
        anchors.fill: parent

        visible: root.solid
        color: Appearance.editor.redactColor
    }

    ShaderEffectSource {
        anchors.fill: parent

        visible: !root.solid
        sourceItem: root.solid ? null : root.source
        sourceRect: Qt.rect(root.x, root.y, root.width, root.height)
        textureSize: Qt.size(Math.max(1, Math.ceil(root.box.width / root.block)), Math.max(1, Math.ceil(root.box.height / root.block)))
        smooth: false
        mipmap: false
    }
}
