import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config

RowLayout {
    id: root

    property var caps: []
    property string through: ""

    spacing: Appearance.keybinds.chordSpacing

    Repeater {
        model: root.caps

        KeyCap {
            required property var modelData

            text: modelData
        }
    }

    StyledText {
        visible: root.through !== ""

        text: Appearance.keybinds.rangeSeparator
        color: Colours.textMuted
        font.pixelSize: Appearance.keybinds.capFontSize
    }

    KeyCap {
        visible: root.through !== ""

        text: root.through
    }

    Item {
        Layout.fillWidth: true
    }
}
