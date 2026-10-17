import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config

RowLayout {
    id: root

    property string glyph: ""
    property string label: ""
    property string value: ""
    property color valueColour: Colours.text

    Layout.fillWidth: true
    Layout.preferredHeight: Appearance.hardware.rowHeight

    spacing: Appearance.hardware.rowSpacing

    Icon {
        Layout.preferredWidth: Appearance.hardware.rowIconWidth

        text: root.glyph
        color: Colours.textMuted
        horizontalAlignment: Text.AlignHCenter
    }

    StyledText {
        text: Appearance.hardware.separator
        color: Colours.textMuted
    }

    StyledText {
        visible: root.label.length > 0

        text: Appearance.hardware.rowTemplate.arg(root.label)
        color: Colours.text
    }

    StyledText {
        Layout.fillWidth: true

        text: root.value
        color: root.valueColour
        font.family: Appearance.font.family.mono
        elide: Text.ElideRight
    }
}
