pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config
import qs.modules.dashboard.components
import qs.services

Card {
    id: root

    property color accent: Colours.accent

    readonly property var config: Appearance.equalizer

    implicitHeight: layout.implicitHeight + Appearance.dash.cardPadding * 2

    ColumnLayout {
        id: layout

        anchors.fill: parent
        anchors.margins: Appearance.dash.cardPadding

        spacing: root.config.sectionSpacing

        RowLayout {
            Layout.fillWidth: true

            StyledText {
                Layout.fillWidth: true

                text: root.config.labelTitle
                color: root.accent
                font.pixelSize: root.config.titleSize
                font.bold: true
            }

            StyledRect {
                implicitWidth: badge.implicitWidth + root.config.badgePadding * 2
                implicitHeight: root.config.badgeHeight

                visible: Equalizer.saved
                radius: height / 2
                color: Colours.trough

                StyledText {
                    id: badge

                    anchors.centerIn: parent

                    text: root.config.labelSaved
                    color: Colours.textMuted
                    font.pixelSize: root.config.badgeSize
                }
            }

            StyledText {
                text: Equalizer.preset
                color: Colours.textBright
                font.pixelSize: root.config.badgeSize
            }
        }

        StyledText {
            Layout.fillWidth: true

            visible: !Equalizer.available
            text: root.config.labelMissing
            color: Colours.warning
            wrapMode: Text.Wrap
            font.pixelSize: root.config.badgeSize
        }

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: bands.implicitHeight

            opacity: Equalizer.available ? 1 : Appearance.control.disabledOpacity

            Row {
                id: bands

                anchors.fill: parent

                Repeater {
                    model: root.config.frequencies.length

                    EqBand {
                        required property int index

                        width: bands.width / root.config.frequencies.length
                        gain: Equalizer.gains[index]
                        label: root.config.labels[index]
                        colour: root.accent

                        onMoved: gain => Equalizer.setGain(index, gain)
                    }
                }
            }

            EqCurve {
                width: parent.width
                height: root.config.sliderHeight

                gains: Equalizer.gains
                colour: root.accent
            }
        }

        GridLayout {
            Layout.fillWidth: true

            columns: root.config.presetColumns
            rowSpacing: root.config.presetSpacing
            columnSpacing: root.config.presetSpacing

            Repeater {
                model: Equalizer.choices

                StyledRect {
                    id: preset

                    required property var modelData

                    readonly property bool active: Equalizer.preset === preset.modelData[0]

                    Layout.fillWidth: true
                    Layout.preferredHeight: root.config.presetHeight

                    radius: root.config.presetRounding
                    color: preset.active ? root.accent : Colours.trough

                    StyledText {
                        anchors.centerIn: parent

                        text: preset.modelData[0]
                        color: preset.active ? Colours.surface : Colours.text
                        font.pixelSize: root.config.presetSize
                        font.bold: preset.active
                    }

                    StateLayer {
                        radius: preset.radius

                        onClicked: Equalizer.usePreset(preset.modelData[0])
                    }
                }
            }
        }
    }
}
