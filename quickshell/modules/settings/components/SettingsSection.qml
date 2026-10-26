import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config

StyledRect {
    id: root

    required property string title
    required property string glyph

    default property alias content: body.data

    readonly property var config: Appearance.settings

    Layout.fillWidth: true
    implicitHeight: body.implicitHeight + header.implicitHeight + root.config.cardSpacing + root.config.cardPadding * 2

    radius: root.config.cardRounding
    color: Colours.pill

    RowLayout {
        id: header

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: root.config.cardPadding

        spacing: root.config.cardSpacing

        Icon {
            text: root.glyph
            color: Colours.accent
            font.pixelSize: root.config.sectionTitleSize
        }

        StyledText {
            Layout.fillWidth: true

            text: root.title
            color: Colours.textMuted
            font.pixelSize: root.config.sectionTitleSize
        }
    }

    ColumnLayout {
        id: body

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: header.bottom
        anchors.leftMargin: root.config.cardPadding
        anchors.rightMargin: root.config.cardPadding
        anchors.topMargin: root.config.cardSpacing

        spacing: root.config.cardSpacing
    }
}
