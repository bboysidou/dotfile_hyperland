import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config

ColumnLayout {
    id: root

    property string title
    property string range
    property var values: []
    property real maximum: 0
    property color colour: Colours.accent

    readonly property var config: Appearance.batteryTab

    Layout.fillWidth: true

    spacing: root.config.chartSpacing

    RowLayout {
        Layout.fillWidth: true

        StyledText {
            Layout.fillWidth: true

            text: root.title
            color: Colours.textMuted
            font.pixelSize: root.config.titleSize
            font.letterSpacing: root.config.titleLetterSpacing
        }

        StyledText {
            text: root.range
            color: Colours.text
            font.pixelSize: root.config.detailSize
            font.family: Appearance.font.family.mono
        }
    }

    Sparkline {
        Layout.fillWidth: true
        Layout.preferredHeight: root.config.chartHeight

        values: root.values
        maximum: root.maximum
        colour: root.colour
        fillOpacity: root.config.chartFillOpacity
        lineWidth: root.config.chartLineWidth
    }
}
