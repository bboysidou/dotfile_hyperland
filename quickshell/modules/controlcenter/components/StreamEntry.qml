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

    readonly property string detail: Audio.streamDetail(root.node)

    interactive: false

    implicitHeight: root.contentHeight + Appearance.control.rowPaddingV * 2

    Keys.onPressed: event => {
        const volume = Nav.horizontal(event);
        if (volume !== 0) {
            Audio.setNodeVolume(root.node, Audio.nodePercent(root.node) + Appearance.audio.step * volume);
            event.accepted = true;
        }
    }
    Keys.onSpacePressed: Audio.toggleMute(root.node)

    Icon {
        text: root.node?.audio?.muted ? Icons.volumeMuted : Icons.volumeHigh
        color: Colours.textMuted
        font.pixelSize: Appearance.control.iconSize

        MouseArea {
            anchors.fill: parent

            cursorShape: Qt.PointingHandCursor

            onClicked: Audio.toggleMute(root.node)
        }
    }

    ColumnLayout {
        Layout.fillWidth: true

        spacing: Appearance.spacing.none

        StyledText {
            Layout.fillWidth: true

            text: Audio.streamLabel(root.node)
            color: Colours.text
            elide: Text.ElideRight
        }

        StyledText {
            Layout.fillWidth: true

            visible: root.detail !== ""
            text: root.detail
            color: Colours.textMuted
            font.pixelSize: Appearance.font.size.small
            elide: Text.ElideRight
        }
    }

    Slider {
        Layout.preferredWidth: Appearance.control.sliderWidth

        value: Audio.nodePercent(root.node) / Appearance.audio.max

        onMoved: value => Audio.setNodeVolume(root.node, Math.round(value * Appearance.audio.max))
    }
}
