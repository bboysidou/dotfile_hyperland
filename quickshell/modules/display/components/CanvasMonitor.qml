import QtQuick
import qs.core.components
import qs.core.config
import qs.modules.display

StyledRect {
    id: root

    required property string name
    required property var settings
    required property real zoom
    required property real originX
    required property real originY
    property bool selected: false
    property bool bezels: false
    property string detail

    readonly property var size: DisplayState.logical(root.settings)

    signal picked
    signal dropped(int x, int y)

    x: root.originX + root.settings.x * root.zoom
    y: root.originY + root.settings.y * root.zoom
    width: root.size.width * root.zoom
    height: root.size.height * root.zoom

    radius: Appearance.display.canvasMonitorRounding
    color: root.bezels ? Colours.elevated : (root.selected ? Colours.accentMuted : Colours.elevated)
    border.width: Appearance.display.canvasBorder
    border.color: root.selected ? Colours.accent : Colours.border
    opacity: root.settings.disabled ? Appearance.display.canvasDisabledOpacity : 1
    z: drag.drag.active ? 2 : (root.selected ? 1 : 0)

    StyledRect {
        anchors.fill: parent
        anchors.margins: Appearance.display.canvasBezel

        visible: root.bezels
        radius: Math.max(0, root.radius - Appearance.display.canvasBezel / 2)
        color: root.selected ? Colours.accentMuted : Colours.trough
    }

    StyledRect {
        id: stand

        anchors.top: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter

        visible: root.bezels
        width: Appearance.display.canvasStandWidth
        height: Appearance.display.canvasStandHeight
        color: Colours.elevated
    }

    StyledRect {
        anchors.top: stand.bottom
        anchors.horizontalCenter: parent.horizontalCenter

        visible: root.bezels
        width: root.width * Appearance.display.canvasBaseRatio
        height: Appearance.display.canvasBaseHeight
        radius: height / 2
        color: Colours.elevated
    }

    Column {
        anchors.centerIn: parent

        StyledText {
            anchors.horizontalCenter: parent.horizontalCenter

            text: root.name
            color: root.selected ? Colours.accent : Colours.textBright
            font.pixelSize: Appearance.display.canvasNameSize
            font.bold: true
        }

        StyledText {
            anchors.horizontalCenter: parent.horizontalCenter

            text: root.detail
            color: Colours.textMuted
            font.pixelSize: Appearance.display.canvasDetailSize
        }
    }

    MouseArea {
        id: drag

        anchors.fill: parent

        cursorShape: Qt.OpenHandCursor
        drag.target: root.settings.disabled || root.settings.mirror ? null : root

        onPressed: root.picked()
        onReleased: {
            if (drag.drag.active || root.x !== root.originX + root.settings.x * root.zoom)
                root.dropped(Math.round((root.x - root.originX) / root.zoom), Math.round((root.y - root.originY) / root.zoom));
        }
    }
}
