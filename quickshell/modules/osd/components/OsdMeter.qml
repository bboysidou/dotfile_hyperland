import QtQuick
import qs.core.components
import qs.core.config
import qs.core.enums

StyledRect {
    id: root

    required property string glyph
    required property int percent
    required property bool muted
    required property bool active

    implicitWidth: Appearance.osd.columnWidth
    implicitHeight: Appearance.osd.columnHeight

    color: Colours.pill
    radius: Appearance.osd.cardRounding
    opacity: root.active ? 1 : Appearance.osd.inactiveOpacity

    Behavior on opacity {
        Anim {
            type: AnimType.defaultEffects
        }
    }

    StyledText {
        id: value

        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: Appearance.osd.paddingV

        text: root.percent
        color: root.active ? Colours.textBright : Colours.text
        font.pixelSize: Appearance.osd.labelSize
    }

    Icon {
        id: glyph

        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: Appearance.osd.paddingV

        text: root.glyph
        color: root.muted ? Colours.textMuted : Colours.accent
        font.pixelSize: Appearance.osd.iconSize
    }

    Meter {
        anchors.top: value.bottom
        anchors.bottom: glyph.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: Appearance.osd.spacing
        anchors.bottomMargin: Appearance.osd.spacing

        implicitWidth: Appearance.osd.meterThickness

        vertical: true
        value: root.percent / Appearance.audio.max
        fillColour: root.muted ? Colours.textMuted : Colours.accent
        rounding: Appearance.osd.meterRounding
    }
}
