pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config
import qs.core.enums
import qs.core.helpers
import qs.services

StyledRect {
    id: root

    required property var node
    property int position: 0
    property bool active: false
    property bool stream: false
    property color accent: Colours.audioOutput
    property string glyph: Icons.speaker
    property string mutedGlyph: Icons.volumeMuted

    property bool entered: false

    readonly property int percent: Audio.nodePercent(root.node)
    readonly property bool muted: root.node?.audio?.muted ?? false
    readonly property string title: root.stream ? Audio.streamLabel(root.node) : Audio.label(root.node)
    readonly property string detail: {
        const config = Appearance.audioPanel;
        if (root.stream)
            return Audio.streamDetail(root.node);
        if (root.active)
            return config.labelActiveDefault;
        return root.node?.name ?? "";
    }
    readonly property color onCard: root.active ? Colours.surface : Colours.text

    signal activated

    Layout.fillWidth: true
    Layout.preferredHeight: root.active ? Appearance.card.activeHeight : Appearance.card.height

    color: root.active ? root.accent : (pointer.containsMouse ? Colours.hover : Colours.pill)
    radius: Appearance.card.rounding
    border.width: root.active ? Appearance.card.activeBorderWidth : Appearance.card.borderWidth
    border.color: root.active ? root.accent : Colours.border

    activeFocusOnTab: !root.stream

    opacity: root.entered ? 1 : 0

    onVisibleChanged: {
        if (!root.visible)
            root.entered = false;
    }

    Keys.onReturnPressed: root.activated()
    Keys.onSpacePressed: Audio.toggleMute(root.node)
    Keys.onPressed: event => {
        const volume = Nav.horizontal(event);
        if (volume !== 0) {
            Audio.setNodeVolume(root.node, root.percent + Appearance.audio.step * volume);
            event.accepted = true;
        }
    }

    transform: Translate {
        y: root.entered ? 0 : Appearance.card.lift

        Behavior on y {
            NumberAnimation {
                duration: Appearance.card.enterDuration
                easing.type: Easing.OutQuint
            }
        }
    }

    Behavior on opacity {
        NumberAnimation {
            duration: Appearance.card.enterDuration
            easing.type: Easing.OutQuint
        }
    }

    Behavior on Layout.preferredHeight {
        Anim {
            type: AnimType.emphasizedSmall
        }
    }

    Behavior on color {
        CAnim {}
    }

    Timer {
        running: root.visible
        interval: Appearance.card.staggerBase + root.position * Appearance.card.staggerStep

        onTriggered: root.entered = true
    }

    StateLayer {
        id: pointer

        disabled: root.stream || root.active
        radius: parent.radius

        onClicked: root.activated()
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.leftMargin: Appearance.card.paddingH
        anchors.rightMargin: Appearance.card.paddingH
        anchors.topMargin: Appearance.card.paddingV
        anchors.bottomMargin: Appearance.card.paddingV

        spacing: Appearance.card.spacing

        RowLayout {
            Layout.fillWidth: true

            spacing: Appearance.card.spacing

            Icon {
                text: root.muted ? root.mutedGlyph : root.glyph
                color: root.onCard
                font.pixelSize: Appearance.card.iconSize
            }

            ColumnLayout {
                Layout.fillWidth: true

                spacing: Appearance.card.textSpacing

                StyledText {
                    Layout.fillWidth: true

                    text: root.title
                    color: root.active ? Colours.surface : Colours.textBright
                    font.pixelSize: Appearance.card.nameSize
                    elide: Text.ElideRight
                }

                StyledText {
                    Layout.fillWidth: true

                    visible: root.detail !== ""
                    text: root.detail
                    color: root.active ? Colours.surface : Colours.textMuted
                    font.pixelSize: Appearance.card.detailSize
                    font.weight: Appearance.font.weightIcon
                    opacity: root.active ? Appearance.audioPanel.orbRingOpacity : 1
                    elide: Text.ElideMiddle
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true

            visible: !root.active
            spacing: Appearance.card.spacing

            Icon {
                Layout.alignment: Qt.AlignVCenter

                text: root.muted ? Icons.volumeMuted : Icons.volumeHigh
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
