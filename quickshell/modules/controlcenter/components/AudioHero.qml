pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config
import qs.services

RowLayout {
    id: root

    required property var node
    required property string title
    required property string subtitle
    property color accent: Colours.audioOutput
    property string glyph: Icons.speaker
    property string mutedGlyph: Icons.volumeMuted

    readonly property int percent: Audio.nodePercent(root.node)
    readonly property bool muted: root.node?.audio?.muted ?? false

    Layout.fillWidth: true
    Layout.preferredHeight: Appearance.audioPanel.heroHeight

    spacing: Appearance.audioPanel.heroSpacing

    VolumeOrb {
        Layout.alignment: Qt.AlignVCenter

        percent: root.percent
        muted: root.muted
        accent: root.accent

        onToggled: Audio.toggleMute(root.node)
        onScrolled: delta => Audio.setNodeVolume(root.node, root.percent + delta)
    }

    ColumnLayout {
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignVCenter

        spacing: Appearance.audioPanel.heroControlSpacing

        ColumnLayout {
            Layout.fillWidth: true

            spacing: Appearance.audioPanel.heroTextSpacing

            StyledText {
                Layout.fillWidth: true

                text: root.title
                color: Colours.textBright
                font.pixelSize: Appearance.audioPanel.heroNameSize
                font.weight: Appearance.font.weightActive
                elide: Text.ElideRight
            }

            StyledText {
                Layout.fillWidth: true

                visible: root.subtitle !== ""
                text: root.subtitle
                color: Colours.textMuted
                font.pixelSize: Appearance.audioPanel.heroDetailSize
                font.weight: Appearance.font.weightIcon
                elide: Text.ElideMiddle
            }
        }

        RowLayout {
            Layout.fillWidth: true

            spacing: Appearance.audioPanel.heroControlSpacing

            Icon {
                Layout.alignment: Qt.AlignVCenter

                text: root.muted ? root.mutedGlyph : root.glyph
                color: root.muted ? Colours.textMuted : root.accent
                font.pixelSize: Appearance.card.iconSize

                MouseArea {
                    anchors.fill: parent

                    cursorShape: Qt.PointingHandCursor

                    onClicked: Audio.toggleMute(root.node)
                }
            }

            Slider {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter

                value: root.percent / Appearance.audio.max
                fillColour: root.muted ? Colours.textMuted : root.accent

                onMoved: value => Audio.setNodeVolume(root.node, Math.round(value * Appearance.audio.max))
            }

            StyledText {
                Layout.preferredWidth: Appearance.card.percentWidth
                Layout.alignment: Qt.AlignVCenter

                horizontalAlignment: Text.AlignRight
                text: Appearance.scale.percentTemplate.arg(root.percent)
                color: Colours.textMuted
                font.pixelSize: Appearance.card.detailSize
            }
        }
    }
}
