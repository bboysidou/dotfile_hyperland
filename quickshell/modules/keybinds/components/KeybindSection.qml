import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config

ColumnLayout {
    id: root

    property string title: ""
    property var binds: []

    Layout.fillWidth: true

    spacing: Appearance.keybinds.rowSpacing

    StyledText {
        Layout.bottomMargin: Appearance.keybinds.sectionTitleSpacing

        text: root.title
        color: Colours.accent
        font.pixelSize: Appearance.keybinds.sectionTitleSize
        font.weight: Appearance.font.weightActive
    }

    Repeater {
        model: root.binds

        KeybindRow {
            required property var modelData

            Layout.preferredHeight: Appearance.keybinds.rowHeight

            caps: modelData.chord
            through: modelData.through
            label: modelData.label
        }
    }
}
