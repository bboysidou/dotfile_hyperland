pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config
import qs.core.helpers
import qs.services

ListRow {
    id: root

    required property var node
    required property bool selected
    required property string glyph
    required property string mutedGlyph

    Keys.onReturnPressed: root.activated()
    Keys.onPressed: event => {
        const volume = Nav.horizontal(event);
        if (volume !== 0) {
            Audio.setNodeVolume(root.node, Audio.nodePercent(root.node) + Appearance.audio.step * volume);
            event.accepted = true;
        }
    }
    Keys.onSpacePressed: Audio.toggleMute(root.node)

    Icon {
        text: root.node?.audio?.muted ? root.mutedGlyph : root.glyph
        color: root.selected ? Colours.highlight : Colours.textMuted
        font.pixelSize: Appearance.control.iconSize

        MouseArea {
            anchors.fill: parent

            cursorShape: Qt.PointingHandCursor

            onClicked: Audio.toggleMute(root.node)
        }
    }

    StyledText {
        Layout.fillWidth: true

        text: Audio.label(root.node)
        color: root.selected ? Colours.textBright : Colours.text
        elide: Text.ElideRight
    }

    Slider {
        Layout.preferredWidth: Appearance.control.sliderWidth

        value: Audio.nodePercent(root.node) / Appearance.audio.max

        onMoved: value => Audio.setNodeVolume(root.node, Math.round(value * Appearance.audio.max))
    }
}
