import QtQuick
import qs.core.helpers

Rectangle {
    id: root

    required property var ann
    required property real zoom

    readonly property var box: Ink.box(root.ann)

    x: root.box.x * root.zoom
    y: root.box.y * root.zoom
    width: root.box.width * root.zoom
    height: root.box.height * root.zoom

    color: root.ann.filled ? root.ann.color : "transparent"
    border.color: root.ann.color
    border.width: root.ann.width * root.zoom
}
