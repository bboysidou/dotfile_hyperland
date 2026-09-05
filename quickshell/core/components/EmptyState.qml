import QtQuick
import QtQuick.Layouts
import qs.core.config

ColumnLayout {
    id: root

    required property string glyph
    required property string title
    required property string subtitle

    property int glyphSize: Appearance.dash.emptyIconSize
    property int titleSize: Appearance.dash.detailArtistSize
    property int subtitleSize: Appearance.dash.cardLabelSize

    spacing: Appearance.dash.emptySpacing

    Icon {
        Layout.alignment: Qt.AlignHCenter

        text: root.glyph
        color: Colours.accent
        font.pixelSize: root.glyphSize
    }

    StyledText {
        Layout.alignment: Qt.AlignHCenter
        Layout.topMargin: Appearance.dash.cardSpacing

        text: root.title
        color: Colours.textBright
        font.pixelSize: root.titleSize
        font.weight: Appearance.font.weightActive
    }

    StyledText {
        Layout.alignment: Qt.AlignHCenter

        text: root.subtitle
        color: Colours.textMuted
        font.pixelSize: root.subtitleSize
    }
}
