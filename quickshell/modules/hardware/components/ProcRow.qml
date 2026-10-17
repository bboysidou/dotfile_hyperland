import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config

RowLayout {
    id: root

    property string name: ""
    property string glyph: ""
    property string value: ""
    property color valueColour: Colours.text
    property string extraGlyph: ""
    property string extra: ""
    property color extraColour: Colours.textMuted

    Layout.fillWidth: true
    Layout.leftMargin: Appearance.hardware.listIndent
    Layout.preferredHeight: Appearance.hardware.rowHeight

    spacing: Appearance.hardware.rowSpacing

    StyledText {
        text: Appearance.hardware.bullet
        color: Colours.textMuted
    }

    StyledText {
        Layout.preferredWidth: Appearance.hardware.procNameWidth

        text: root.name
        color: Colours.text
        elide: Text.ElideRight
    }

    Icon {
        text: root.glyph
        color: root.valueColour
    }

    StyledText {
        Layout.fillWidth: root.extra.length === 0
        Layout.preferredWidth: Appearance.hardware.procValueWidth

        text: root.value
        color: root.valueColour
        font.family: Appearance.font.family.mono
        elide: Text.ElideRight
    }

    Icon {
        visible: root.extra.length > 0

        text: root.extraGlyph
        color: root.extraColour
    }

    StyledText {
        Layout.fillWidth: true

        visible: root.extra.length > 0
        text: root.extra
        color: root.extraColour
        font.family: Appearance.font.family.mono
        elide: Text.ElideRight
    }
}
