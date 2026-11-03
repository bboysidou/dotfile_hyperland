import QtQuick
import qs.core.config
import qs.core.helpers

Rectangle {
    id: root

    required property var ann
    required property real zoom

    x: (root.ann.x1 - root.ann.radius) * root.zoom
    y: (root.ann.y1 - root.ann.radius) * root.zoom
    width: root.ann.radius * 2 * root.zoom
    height: width
    radius: width / 2

    color: root.ann.color

    Text {
        anchors.centerIn: parent

        text: root.ann.number
        color: Ink.luminance(root.ann.color) > Appearance.editor.lightThreshold ? Colours.shadow : "white"
        font.family: Appearance.font.family.sans
        font.weight: Font.Bold
        font.pixelSize: root.height * Appearance.editor.markerFont
    }
}
