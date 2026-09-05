import QtQuick
import qs.core.config
import qs.core.enums

StyledRect {
    id: root

    required property string text
    required property bool shown

    implicitWidth: label.implicitWidth + Appearance.bar.trayTooltipPaddingH * 2
    implicitHeight: label.implicitHeight + Appearance.bar.trayTooltipPaddingV * 2

    color: Colours.pill
    radius: Appearance.bar.trayTooltipRounding
    opacity: root.shown ? 1 : 0
    visible: root.opacity > 0

    Behavior on opacity {
        Anim {
            type: AnimType.defaultEffects
        }
    }

    StyledText {
        id: label

        anchors.centerIn: parent

        text: root.text
        color: Colours.textBright
        font.pixelSize: Appearance.font.size.small
    }
}
