import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config
import qs.modules.dashboard.components
import qs.services

Card {
    id: root

    implicitHeight: (layout.implicitHeight || 0) + Appearance.dash.cardPadding * 2

    ColumnLayout {
        id: layout

        anchors.fill: parent
        anchors.margins: Appearance.dash.cardPadding

        spacing: Appearance.dash.cardSpacing

        CardLabel {
            Layout.fillWidth: true

            icon: Icons.prayersTab
            label: Prayer.place.city
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: Appearance.prayer.arcSize

            Item {
                anchors.centerIn: parent

                implicitWidth: Appearance.prayer.arcSize
                implicitHeight: Appearance.prayer.arcSize

                GaugeArc {
                    anchors.fill: parent

                    value: Prayer.progress
                    startAngle: Appearance.prayer.arcStart
                    span: Appearance.prayer.arcSpan
                    strokeWidth: Appearance.prayer.arcSize * Appearance.prayer.arcThicknessRatio
                    fgColour: Prayer.urgent ? Colours.critical : Colours.accent
                }

                ColumnLayout {
                    anchors.centerIn: parent

                    spacing: Appearance.spacing.none

                    StyledText {
                        Layout.alignment: Qt.AlignHCenter

                        text: Prayer.next?.label ?? Appearance.prayer.placeholder
                        color: Colours.textMuted
                        font.pixelSize: Appearance.prayer.nextNameSize
                    }

                    StyledText {
                        Layout.alignment: Qt.AlignHCenter

                        text: Prayer.next?.time ?? Appearance.prayer.placeholder
                        color: Colours.textBright
                        font.pixelSize: Appearance.prayer.nextTimeSize
                        font.weight: Appearance.font.weightActive
                    }

                    StyledText {
                        Layout.alignment: Qt.AlignHCenter

                        text: Prayer.countdown
                        color: Prayer.urgent ? Colours.critical : Colours.accent
                        font.weight: Appearance.font.weightActive
                    }
                }
            }
        }
    }
}
