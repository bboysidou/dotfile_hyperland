import QtQuick
import qs.core.config

Rectangle {
    id: root

    required property var spot
    required property real zoom

    x: root.spot.x * root.zoom - width / 2
    y: root.spot.y * root.zoom - height / 2
    width: Appearance.editor.handleSize
    height: width
    radius: width / 2

    color: Colours.surface
    border.color: Colours.accent
    border.width: Appearance.editor.handleBorder
}
