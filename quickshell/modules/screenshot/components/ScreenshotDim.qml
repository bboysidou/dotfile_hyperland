import QtQuick
import qs.core.config

Item {
    id: root

    property var hole: null

    readonly property real holeX: root.hole ? root.hole.x : 0
    readonly property real holeY: root.hole ? root.hole.y : 0
    readonly property real holeWidth: root.hole ? root.hole.width : 0
    readonly property real holeHeight: root.hole ? root.hole.height : root.height

    Rectangle {
        x: 0
        y: 0
        width: root.width
        height: root.holeY

        color: Colours.shadow
        opacity: Appearance.screenshot.dimOpacity
    }

    Rectangle {
        x: 0
        y: root.holeY + root.holeHeight
        width: root.width
        height: root.height - y

        color: Colours.shadow
        opacity: Appearance.screenshot.dimOpacity
    }

    Rectangle {
        x: 0
        y: root.holeY
        width: root.holeX
        height: root.holeHeight

        color: Colours.shadow
        opacity: Appearance.screenshot.dimOpacity
    }

    Rectangle {
        x: root.holeX + root.holeWidth
        y: root.holeY
        width: root.width - x
        height: root.holeHeight

        color: Colours.shadow
        opacity: Appearance.screenshot.dimOpacity
    }
}
