import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config

RowLayout {
    id: root

    property color colour: Colours.trough
    property string label: ""

    spacing: Appearance.hardware.legendSpacing

    Rectangle {
        implicitWidth: Appearance.hardware.legendSwatch
        implicitHeight: Appearance.hardware.legendSwatch

        radius: Appearance.rounding.tiny
        color: root.colour
    }

    StyledText {
        text: root.label
        color: Colours.text
        font.pixelSize: Appearance.font.size.small
    }
}
