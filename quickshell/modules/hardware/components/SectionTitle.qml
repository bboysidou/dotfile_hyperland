import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config

ColumnLayout {
    id: root

    property string glyph: ""
    property string title: ""
    property color accent: Colours.accent

    Layout.fillWidth: true

    spacing: Appearance.hardware.rowSpacing

    RowLayout {
        Layout.fillWidth: true

        spacing: Appearance.hardware.rowSpacing

        Icon {
            text: root.glyph
            color: root.accent
            font.pixelSize: Appearance.hardware.headerIconSize
        }

        StyledText {
            Layout.fillWidth: true

            text: root.title
            color: Colours.textBright
            font.pixelSize: Appearance.hardware.titleSize
            font.weight: Appearance.font.weightActive
            wrapMode: Text.Wrap
        }
    }

    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: Appearance.hardware.titleRuleHeight

        color: Colours.gauge
        opacity: Appearance.hardware.ruleOpacity
    }
}
