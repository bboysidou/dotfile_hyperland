import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.core.components
import qs.core.config

Pill {
    id: root

    required property string glyph
    required property int percent
    required property color ringColour
    property var launchCommand: []

    readonly property color stateColour: {
        if (percent >= Appearance.bar.usageCritical)
            return Colours.critical;
        if (percent >= Appearance.bar.usageWarning)
            return Colours.warning;
        return Colours.text;
    }

    readonly property color stateRingColour: {
        if (percent >= Appearance.bar.usageCritical)
            return Colours.critical;
        if (percent >= Appearance.bar.usageWarning)
            return Colours.warning;
        return ringColour;
    }

    Layout.rightMargin: Appearance.bar.pillMarginRight

    interactive: root.launchCommand.length > 0

    onClicked: Quickshell.execDetached(root.launchCommand)

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
