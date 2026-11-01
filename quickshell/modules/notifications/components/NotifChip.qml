import qs.core.components
import qs.core.config

Pill {
    id: root

    required property string label
    property string glyph: ""
    property bool accent: false

    color: root.accent ? Colours.accent : root.hovered ? Colours.hover : Colours.trough
    paddingV: Appearance.notif.actionPaddingV
    paddingH: Appearance.notif.actionPaddingH
    interactive: true

    Icon {
        visible: root.glyph !== ""
        text: root.glyph
        color: root.accent ? Colours.surface : Colours.textBright
        font.pixelSize: Appearance.font.size.small
    }

    StyledText {
        text: root.label
        color: root.accent ? Colours.surface : Colours.textBright
        font.pixelSize: Appearance.font.size.small
    }
}
