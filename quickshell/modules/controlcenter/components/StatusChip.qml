import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config

StyledRect {
    id: root

    property string glyph
    property string label
    property color tone: Colours.textMuted

    readonly property var config: Appearance.batteryTab

    implicitWidth: row.implicitWidth + root.config.chipPaddingH * 2
    implicitHeight: row.implicitHeight + root.config.chipPaddingV * 2

    radius: root.config.chipRounding
    color: Qt.alpha(root.tone, root.config.chipTint)

    RowLayout {
        id: row

        anchors.centerIn: parent

        spacing: root.config.chipSpacing

        Icon {
            text: root.glyph
            color: root.tone
            font.pixelSize: root.config.chipIconSize
        }

        StyledText {
            text: root.label
            color: root.tone
            font.pixelSize: root.config.detailSize
        }
    }
}
