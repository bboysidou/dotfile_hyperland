import QtQuick
import qs.core.components
import qs.core.config

StyledRect {
    id: root

    property string text: ""

    implicitWidth: Math.max(Appearance.keybinds.capMinWidth, label.implicitWidth + Appearance.keybinds.capPaddingH * 2)
    implicitHeight: label.implicitHeight + Appearance.keybinds.capPaddingV * 2

    color: Colours.trough
    radius: Appearance.keybinds.capRounding
    border.width: Appearance.keybinds.capBorderWidth
    border.color: Colours.border

    StyledText {
        id: label

        anchors.centerIn: parent

        text: root.text
        color: Colours.textBright
        font.pixelSize: Appearance.keybinds.capFontSize
    }
}
