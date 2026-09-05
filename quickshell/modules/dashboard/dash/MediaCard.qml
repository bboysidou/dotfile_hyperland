import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config
import qs.core.helpers
import qs.modules.dashboard.components
import qs.modules.dashboard.media
import qs.services

Card {
    id: root

    property bool active: true

    implicitHeight: (layout.implicitHeight || 0) + Appearance.dash.cardPadding * 2

    ColumnLayout {
        id: layout

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: Appearance.dash.cardPadding

        spacing: Appearance.dash.cardSpacing

        Vinyl {
            Layout.alignment: Qt.AlignHCenter

            active: root.active

            coverSize: Appearance.dash.vinylSizeSmall
            magnitude: Appearance.dash.visualiserMagnitudeSmall
            labelSize: Appearance.dash.vinylLabelSizeSmall
        }

        Marquee {
            Layout.fillWidth: true
            Layout.topMargin: Appearance.dash.cardSpacing

            full: Players.trackTitle
            budget: Appearance.dash.mediaTitleBudget
            color: Colours.textBright
            font.weight: Appearance.font.weightActive
        }

        Marquee {
            Layout.fillWidth: true

            full: Players.trackArtist
            budget: Appearance.dash.mediaTitleBudget
            color: Colours.textMuted
            font.pixelSize: Appearance.dash.cardLabelSize
        }

        Meter {
            Layout.fillWidth: true
            Layout.topMargin: Appearance.dash.cardSpacing
            Layout.preferredHeight: Appearance.dash.seekHeight

            value: Players.progress
            fillColour: Colours.media
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: Appearance.dash.cardSpacing

            spacing: Appearance.dash.mediaControlSpacing

            Icon {
                text: Icons.skipPrevious
                color: Players.canGoPrevious ? Colours.text : Colours.textMuted
                font.pixelSize: Appearance.dash.mediaControlSize

                StateLayer {
                    radius: parent.height / 2
                    disabled: !Players.canGoPrevious

                    onClicked: Players.previous()
                }
            }

            Icon {
                text: Players.playIcon
                color: Colours.accent
                font.pixelSize: Appearance.dash.mediaControlSize

                StateLayer {
                    radius: parent.height / 2
                    disabled: !Players.available

                    onClicked: Players.togglePlaying()
                }
            }

            Icon {
                text: Icons.skipNext
                color: Players.canGoNext ? Colours.text : Colours.textMuted
                font.pixelSize: Appearance.dash.mediaControlSize

                StateLayer {
                    radius: parent.height / 2
                    disabled: !Players.canGoNext

                    onClicked: Players.next()
                }
            }
        }
    }
}
