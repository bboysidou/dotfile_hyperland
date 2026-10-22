import QtQuick
import qs.core.components
import qs.core.config

StyledRect {
    id: root

    property string value
    property string unit

    implicitWidth: Appearance.powerPanel.timeTileSize
    implicitHeight: Appearance.powerPanel.timeTileSize

    radius: Appearance.powerPanel.timeTileRounding
    color: Colours.elevated

    Column {
        anchors.centerIn: parent

        StyledText {
            anchors.horizontalCenter: parent.horizontalCenter

            text: root.value
            color: Colours.accent
            font.pixelSize: Appearance.powerPanel.timeDigitSize
            font.bold: true
        }

        StyledText {
            anchors.horizontalCenter: parent.horizontalCenter

            text: root.unit
            color: Colours.textMuted
            font.pixelSize: Appearance.powerPanel.timeUnitSize
        }
    }
}
