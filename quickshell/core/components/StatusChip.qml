import QtQuick
import QtQuick.Layouts
import qs.core.config

StyledRect {
    id: root

    property string glyph
    property string label
    property color tone: Colours.textMuted

    implicitWidth: row.implicitWidth + Appearance.chip.paddingH * 2
    implicitHeight: row.implicitHeight + Appearance.chip.paddingV * 2

    radius: Appearance.chip.rounding
    color: Qt.alpha(root.tone, Appearance.chip.tint)

    RowLayout {
        id: row

        anchors.fill: parent
        anchors.leftMargin: Appearance.chip.paddingH
        anchors.rightMargin: Appearance.chip.paddingH

        spacing: Appearance.chip.spacing

        Icon {
            text: root.glyph
            color: root.tone
            font.pixelSize: Appearance.chip.iconSize
        }

        ScrollText {
            Layout.fillWidth: true

            text: root.label
            color: root.tone
            font.pixelSize: Appearance.chip.textSize
        }
    }
}
