pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config

RowLayout {
    id: root

    required property int count
    required property string label
    required property string title
    required property string detail
    required property string glyph
    required property string action
    property color emphasis: Colours.textBright
    property bool actionable: true

    property real roll: 1

    signal activated

    Layout.fillWidth: true
    Layout.preferredHeight: Appearance.notifPanel.heroHeight

    spacing: Appearance.notifPanel.heroSpacing

    onCountChanged: rollAnim.restart()

    NumberAnimation {
        id: rollAnim

        target: root
        property: "roll"
        from: 0
        to: 1
        duration: Appearance.notifPanel.countRollDuration
        easing.type: Easing.OutExpo
    }

    ColumnLayout {
        Layout.preferredWidth: Appearance.notifPanel.countWidth
        Layout.alignment: Qt.AlignVCenter

        spacing: Appearance.notifPanel.countSpacing

        StyledText {
            Layout.fillWidth: true

            text: root.count
            color: root.emphasis
            font.pixelSize: Appearance.notifPanel.countSize
            font.weight: Appearance.font.weightActive
            opacity: root.roll

            transform: Translate {
                y: Appearance.notifPanel.countRollLift * (1 - root.roll)
            }
        }

        StyledText {
            Layout.fillWidth: true

            text: root.label
            color: Colours.textMuted
            font.pixelSize: Appearance.notifPanel.countLabelSize
            font.weight: Appearance.font.weightIcon
            elide: Text.ElideRight
        }
    }

    ColumnLayout {
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignVCenter

        spacing: Appearance.notifPanel.heroControlSpacing

        ColumnLayout {
            Layout.fillWidth: true

            spacing: Appearance.notifPanel.heroTextSpacing

            StyledText {
                Layout.fillWidth: true

                text: root.title
                color: Colours.textBright
                font.pixelSize: Appearance.notifPanel.heroNameSize
                font.weight: Appearance.font.weightActive
                elide: Text.ElideRight
            }

            StyledText {
                Layout.fillWidth: true

                text: root.detail
                color: Colours.textMuted
                font.pixelSize: Appearance.notifPanel.heroDetailSize
                font.weight: Appearance.font.weightIcon
                elide: Text.ElideRight
            }
        }

        RowLayout {
            Layout.fillWidth: true

            spacing: Appearance.notifPanel.heroControlSpacing

            Icon {
                Layout.alignment: Qt.AlignVCenter

                text: root.glyph
                color: root.emphasis
                font.pixelSize: Appearance.card.iconSize
            }

            Item {
                Layout.fillWidth: true
            }

            Pill {
                Layout.alignment: Qt.AlignVCenter

                interactive: root.actionable
                paddingH: Appearance.notifPanel.chipPaddingH
                paddingV: Appearance.notifPanel.chipPaddingV
                radius: Appearance.rounding.full
                color: root.actionable && hovered ? Colours.hover : Colours.pill
                border.width: Appearance.notifPanel.chipBorderWidth
                border.color: Colours.border
                opacity: root.actionable ? 1 : Appearance.control.disabledOpacity

                onClicked: root.activated()

                StyledText {
                    text: root.action
                    color: Colours.text
                    font.pixelSize: Appearance.notifPanel.chipFontSize
                }
            }
        }
    }
}
