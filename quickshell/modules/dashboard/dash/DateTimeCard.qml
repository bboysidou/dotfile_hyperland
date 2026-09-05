import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.core.components
import qs.core.config
import qs.modules.dashboard.components
import qs.services

Card {
    id: root

    readonly property string user: Quickshell.env("USER")

    implicitHeight: (layout.implicitHeight || 0) + Appearance.dash.cardPadding * 2

    ColumnLayout {
        id: layout

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.margins: Appearance.dash.cardPadding

        spacing: Appearance.dash.cardSpacing

        RowLayout {
            Layout.fillWidth: true

            spacing: Appearance.dash.userSpacing

            ClippingRectangle {
                id: avatar

                readonly property rect ink: glyphMetrics.tightBoundingRect
                readonly property real inkLeft: avatar.ink.x - glyphMetrics.boundingRect.x
                readonly property real inkTop: avatar.ink.y - glyphMetrics.boundingRect.y

                Layout.preferredWidth: Appearance.dash.userAvatarSize
                Layout.preferredHeight: Appearance.dash.userAvatarSize

                radius: width / 2
                color: Colours.trough

                TextMetrics {
                    id: glyphMetrics

                    font: logo.font
                    text: logo.text
                }

                Icon {
                    id: logo

                    x: (avatar.width - avatar.ink.width) / 2 - avatar.inkLeft
                    y: (avatar.height - avatar.ink.height) / 2 - avatar.inkTop

                    horizontalAlignment: Text.AlignLeft
                    text: Icons.arch
                    color: Colours.arch
                    font.pixelSize: Appearance.dash.userAvatarIconSize
                }
            }

            StyledText {
                Layout.fillWidth: true

                text: root.user
                color: Colours.textBright
                font.pixelSize: Appearance.dash.userNameSize
                font.weight: Appearance.font.weightActive
                elide: Text.ElideRight
            }
        }

        StyledText {
            text: Qt.formatDateTime(Time.now, Appearance.dash.dateTimeFormat)
            color: Colours.textBright
            font.pixelSize: Appearance.dash.dateTimeSize
            font.weight: Appearance.font.weightActive
        }

        StyledText {
            Layout.fillWidth: true

            text: Qt.formatDateTime(Time.now, Appearance.dash.dateDayFormat)
            color: Colours.accent
            elide: Text.ElideRight
        }

        StyledText {
            Layout.fillWidth: true

            text: Qt.formatDateTime(Time.now, Appearance.dash.dateRestFormat)
            color: Colours.textMuted
            font.pixelSize: Appearance.dash.cardLabelSize
            elide: Text.ElideRight
        }
    }
}
