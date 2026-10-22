import QtQuick
import qs.core.components
import qs.core.config

Column {
    id: root

    property real value: 0
    property string text
    property string glyph
    property string label
    property color colour: Colours.accent

    readonly property var config: Appearance.weather

    spacing: root.config.ringSpacing

    Item {
        anchors.horizontalCenter: parent.horizontalCenter

        width: root.config.ringSize
        height: root.config.ringSize

        Ring {
            anchors.fill: parent

            value: Math.max(0, Math.min(1, root.value))
            colour: root.colour
            radiusRatio: root.config.ringRadiusRatio
            thicknessRatio: root.config.ringThicknessRatio
        }

        StyledText {
            anchors.centerIn: parent

            text: root.text
            color: Colours.textBright
            font.pixelSize: root.config.ringValueSize
        }
    }

    Row {
        anchors.horizontalCenter: parent.horizontalCenter

        spacing: root.config.pillSpacing

        Icon {
            text: root.glyph
            color: Colours.textMuted
            font.pixelSize: root.config.ringLabelSize
        }

        StyledText {
            text: root.label
            color: Colours.textMuted
            font.pixelSize: root.config.ringLabelSize
        }
    }
}
