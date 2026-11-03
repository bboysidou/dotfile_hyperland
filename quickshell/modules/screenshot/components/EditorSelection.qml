pragma ComponentBehavior: Bound

import QtQuick
import qs.core.config
import qs.core.helpers

Item {
    id: root

    property var ann: null
    required property real zoom

    readonly property var box: root.ann ? Ink.box(root.ann) : ({
            x: 0,
            y: 0,
            width: 0,
            height: 0
        })
    readonly property real pad: Appearance.editor.selectionPad

    Rectangle {
        x: root.box.x * root.zoom - root.pad
        y: root.box.y * root.zoom - root.pad
        width: root.box.width * root.zoom + root.pad * 2
        height: root.box.height * root.zoom + root.pad * 2

        color: "transparent"
        border.color: Colours.accent
        border.width: Appearance.editor.selectionWidth
    }

    Repeater {
        model: root.ann ? Ink.handles(root.ann) : []

        EditorHandle {
            required property var modelData

            spot: modelData
            zoom: root.zoom
        }
    }
}
