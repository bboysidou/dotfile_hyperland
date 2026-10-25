import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config
import qs.core.helpers

RowLayout {
    id: root

    property string glyph: ""
    property string label: ""
    property real mbps: 0
    property color accent: Colours.accent

    readonly property var config: Appearance.speedTest
    readonly property var reading: Fmt.bitrate(root.mbps, root.config.valueDecimals)

    spacing: root.config.resultSpacing

    Icon {
        text: root.glyph
        color: root.accent
        font.pixelSize: root.config.resultGlyphSize
    }

    ColumnLayout {
        spacing: root.config.resultTextSpacing

        StyledText {
            text: root.label
            color: Colours.textMuted
            font.pixelSize: root.config.resultLabelSize
        }

        RowLayout {
            spacing: root.config.unitSpacing

            StyledText {
                text: root.reading.value
                color: Colours.textBright
                font.pixelSize: root.config.resultValueSize
            }

            StyledText {
                Layout.alignment: Qt.AlignBaseline

                text: root.reading.unit
                color: root.accent
                font.pixelSize: root.config.resultUnitSize
            }
        }
    }

    Item {
        Layout.fillWidth: true
    }
}
