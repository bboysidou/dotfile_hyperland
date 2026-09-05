import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.core.components
import qs.core.config
import qs.core.constants
import qs.core.helpers
import qs.services

Pill {
    id: root

    readonly property color stateColour: {
        if (MouseBattery.percent <= Appearance.bar.mouseCritical)
            return Colours.critical;
        if (MouseBattery.percent <= Appearance.bar.mouseWarning)
            return Colours.warning;
        return Colours.text;
    }

    Layout.rightMargin: Appearance.bar.pillMarginRight

    visible: MouseBattery.available
    interactive: true

    onClicked: Quickshell.execDetached(Commands.mouseSettings)

    Icon {
        text: Glyphs.mouse(MouseBattery.charging)
        color: root.stateColour
    }

    StyledText {
        text: Appearance.scale.percentTemplate.arg(MouseBattery.percent)
        color: root.stateColour
    }

    Icon {
        text: Glyphs.batteryRamp(MouseBattery.percent, MouseBattery.charging)
        color: root.stateColour
    }
}
