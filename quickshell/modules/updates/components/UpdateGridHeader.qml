import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config

RowLayout {
    id: root

    implicitHeight: Appearance.updates.gridHeaderHeight

    spacing: Appearance.updates.rowSpacing

    StyledText {
        Layout.fillWidth: true

        text: Appearance.updates.columnPackage
        color: Colours.textMuted
        font.pixelSize: Appearance.font.size.tiny
        font.capitalization: Font.AllUppercase
        font.letterSpacing: Appearance.updates.gridLetterSpacing
    }

    StyledText {
        Layout.preferredWidth: Appearance.updates.versionColumnWidth

        text: Appearance.updates.columnCurrent
        color: Colours.textMuted
        font.pixelSize: Appearance.font.size.tiny
        font.capitalization: Font.AllUppercase
        font.letterSpacing: Appearance.updates.gridLetterSpacing
    }

    StyledText {
        Layout.preferredWidth: Appearance.updates.versionColumnWidth

        text: Appearance.updates.columnNew
        color: Colours.textMuted
        font.pixelSize: Appearance.font.size.tiny
        font.capitalization: Font.AllUppercase
        font.letterSpacing: Appearance.updates.gridLetterSpacing
    }
}
