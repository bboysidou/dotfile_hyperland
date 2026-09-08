import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config

RowLayout {
    id: root

    property var caps: []
    property string through: ""
    property string label: ""

    Layout.fillWidth: true

    spacing: Appearance.keybinds.rowSpacingH

    KeyChord {
        id: chord

        Layout.fillWidth: false
        Layout.preferredWidth: Math.max(Appearance.keybinds.chordMinWidth, chord.implicitWidth)

        caps: root.caps
        through: root.through
    }

    StyledText {
        Layout.fillWidth: true

        text: root.label
        color: Colours.text
        font.pixelSize: Appearance.keybinds.labelSize
        elide: Text.ElideRight
    }
}
