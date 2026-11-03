import QtQuick
import qs.core.components
import qs.core.config
import qs.modules.keybinds.components

StyledRect {
    id: root

    required property string icon
    required property string label
    property string hint: ""
    property bool active: false
    property bool disabled: false

    signal triggered

    implicitWidth: Math.max(Appearance.editor.buttonMinWidth, Math.max(glyph.implicitWidth, caption.implicitWidth, cap.implicitWidth) + Appearance.editor.buttonPaddingH * 2)
    implicitHeight: glyph.implicitHeight + caption.implicitHeight + Appearance.editor.buttonGap + (cap.visible ? cap.implicitHeight + Appearance.editor.buttonGap : 0) + Appearance.editor.buttonPaddingV * 2

    radius: Appearance.editor.buttonRounding
    color: root.active ? Colours.elevated : layer.containsMouse ? Colours.hover : "transparent"
    border.width: Appearance.editor.buttonBorder
    border.color: root.active ? Colours.border : "transparent"
    opacity: root.disabled ? Appearance.editor.disabledOpacity : 1

    Icon {
        id: glyph

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: Appearance.editor.buttonPaddingV

        text: root.icon
        color: root.active ? Colours.accent : Colours.textBright
        font.pixelSize: Appearance.editor.iconSize
    }

    StyledText {
        id: caption

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: glyph.bottom
        anchors.topMargin: Appearance.editor.buttonGap

        text: root.label
        color: root.active ? Colours.textBright : Colours.text
        font.pixelSize: Appearance.font.size.small
        font.weight: Font.Medium
    }

    KeyCap {
        id: cap

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: caption.bottom
        anchors.topMargin: Appearance.editor.buttonGap

        visible: root.hint !== ""
        text: root.hint
    }

    StateLayer {
        id: layer

        disabled: root.disabled

        onClicked: root.triggered()
    }
}
