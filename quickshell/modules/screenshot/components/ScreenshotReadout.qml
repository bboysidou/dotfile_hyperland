import QtQuick
import qs.core.components
import qs.core.config

Rectangle {
    id: root

    property alias text: label.text
    property real pointerX: 0
    property real pointerY: 0

    readonly property real offset: Appearance.screenshot.readoutOffset
    readonly property bool flipX: root.pointerX + root.offset + root.width > (root.parent?.width ?? 0)
    readonly property bool flipY: root.pointerY + root.offset + root.height > (root.parent?.height ?? 0)

    x: root.flipX ? root.pointerX - root.offset - root.width : root.pointerX + root.offset
    y: root.flipY ? root.pointerY - root.offset - root.height : root.pointerY + root.offset
    implicitWidth: label.implicitWidth + Appearance.screenshot.readoutPaddingH * 2
    implicitHeight: label.implicitHeight + Appearance.screenshot.readoutPaddingV * 2

    color: Colours.surface
    radius: Appearance.screenshot.readoutRounding
    border.width: 1
    border.color: Colours.border

    StyledText {
        id: label

        anchors.centerIn: parent

        font.family: Appearance.font.family.mono
        font.pixelSize: Appearance.screenshot.readoutSize
    }
}
