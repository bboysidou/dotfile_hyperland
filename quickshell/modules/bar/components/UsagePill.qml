import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.core.components
import qs.core.config
import qs.core.helpers
import qs.modules.hardware

Pill {
    id: root

    required property string glyph
    required property int percent
    required property color ringColour
    required property string section
    property var launchCommand: []

    readonly property color stateColour: Tone.usage(root.percent, Colours.text)
    readonly property color stateRingColour: Tone.usage(root.percent, root.ringColour)

    Layout.rightMargin: Appearance.bar.pillMarginRight

    interactive: true
    secondary: root.launchCommand.length > 0

    onClicked: HardwareState.toggle(root.section)
    onSecondaryClicked: Quickshell.execDetached(root.launchCommand)

    Icon {
        text: root.glyph
        color: root.stateColour
    }

    StyledText {
        text: Appearance.scale.percentTemplate.arg(root.percent)
        color: root.stateColour
    }

    Ring {
        Layout.leftMargin: Appearance.bar.ringMarginLeft

        value: root.percent / 100
        colour: root.stateRingColour
    }
}
