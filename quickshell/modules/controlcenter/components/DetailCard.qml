import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config

StyledRect {
    id: root

    property string glyph
    property string title

    default property alias content: body.data
    property alias trailing: trailingSlot.data

    readonly property var config: Appearance.batteryTab

    Layout.fillWidth: true
    Layout.preferredHeight: layout.implicitHeight + root.config.cardPadding * 2

    radius: Appearance.powerPanel.cardRounding
    color: Colours.elevated

    ColumnLayout {
        id: layout

        anchors.fill: parent
        anchors.margins: root.config.cardPadding

        spacing: root.config.cardSpacing

        RowLayout {
            Layout.fillWidth: true

            spacing: root.config.cardSpacing

            Icon {
                text: root.glyph
                color: Colours.accent
                font.pixelSize: root.config.iconSize
            }

            StyledText {
                Layout.fillWidth: true

                text: root.title
                color: Colours.textMuted
                font.pixelSize: root.config.titleSize
                font.letterSpacing: root.config.titleLetterSpacing
                elide: Text.ElideRight
            }

            RowLayout {
                id: trailingSlot
            }
        }

        ColumnLayout {
            id: body

            Layout.fillWidth: true

            spacing: root.config.cardSpacing
        }
    }
}
