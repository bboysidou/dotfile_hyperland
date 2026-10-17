import QtQuick.Layouts
import qs.core.components
import qs.core.config

RowLayout {
    spacing: Appearance.share.headerSpacing

    Icon {
        text: Icons.shareTitle
        color: Colours.accent
        font.pixelSize: Appearance.share.iconSize
    }

    ColumnLayout {
        Layout.fillWidth: true

        spacing: Appearance.spacing.none

        StyledText {
            Layout.fillWidth: true

            text: Appearance.share.title
            color: Colours.textBright
            font.pixelSize: Appearance.share.titleSize
        }

        StyledText {
            Layout.fillWidth: true

            text: Appearance.share.subtitle
            color: Colours.textMuted
            font.pixelSize: Appearance.share.bodySize
        }
    }
}
