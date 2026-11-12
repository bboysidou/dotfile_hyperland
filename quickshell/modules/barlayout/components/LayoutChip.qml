import QtQuick
import qs.core.components
import qs.core.config
import qs.core.enums
import qs.modules.barlayout
import qs.services

StyledRect {
    id: root

    required property string entry
    property bool dragged: false
    property bool ghost: false

    readonly property var config: Appearance.barLayout
    readonly property bool off: !Prefs.barEnabled(root.entry)
    readonly property bool locked: BarLayoutState.locked(root.entry)
    readonly property bool pinned: root.entry === BarEntry.media
    readonly property bool selected: BarLayoutState.selected === root.entry
    readonly property string glyph: root.locked ? Icons.lockScreen : root.pinned ? Icons.pin : ""

    signal pressed(real x, real y)
    signal moved(real x, real y)
    signal released(real x, real y)

    implicitWidth: row.implicitWidth + root.config.chipPadding * 2
    implicitHeight: root.config.chipHeight

    radius: root.config.chipRounding
    color: root.ghost ? Colours.accent : Colours.elevated
    border.width: root.selected && !root.ghost ? root.config.chipBorder : 0
    border.color: Colours.accent
    opacity: root.dragged ? root.config.draggedOpacity : root.off ? root.config.offOpacity : 1

    Row {
        id: row

        anchors.centerIn: parent

        spacing: root.config.chipGlyphSpacing

        Icon {
            anchors.verticalCenter: parent.verticalCenter

            visible: root.glyph !== ""
            text: root.glyph
            color: root.ghost ? Colours.surface : Colours.textMuted
            font.pixelSize: root.config.chipGlyphSize
        }

        StyledText {
            anchors.verticalCenter: parent.verticalCenter

            text: BarLayoutState.label(root.entry)
            color: root.ghost ? Colours.surface : Colours.textBright
            font.pixelSize: root.config.chipTextSize
        }
    }

    StateLayer {
        id: layer

        radius: root.radius
        visible: !root.ghost
        disabled: !BarLayoutState.available(root.entry)
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        preventStealing: true
        cursorShape: layer.pressed ? Qt.ClosedHandCursor : Qt.OpenHandCursor

        onPressed: mouse => {
            BarLayoutState.selected = root.entry;
            if (mouse.button === Qt.LeftButton)
                root.pressed(mouse.x, mouse.y);
        }
        onPositionChanged: mouse => {
            if (layer.pressedButtons & Qt.LeftButton)
                root.moved(mouse.x, mouse.y);
        }
        onReleased: mouse => {
            if (mouse.button === Qt.LeftButton)
                root.released(mouse.x, mouse.y);
        }
        onClicked: mouse => {
            if (mouse.button === Qt.RightButton)
                BarLayoutState.toggleOff(root.entry);
        }
    }
}
