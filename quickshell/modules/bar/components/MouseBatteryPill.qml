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
        if (MouseBattery.charging)
            return Colours.accent;
        if (MouseBattery.percent < Appearance.powerPanel.criticalPercent)
            return Colours.critical;
        if (MouseBattery.percent < Prefs.mouseWarn)
            return Colours.warning;
        return Colours.accent;
    }

    trailing: Appearance.bar.pillMarginRight

    visible: MouseBattery.available
    interactive: true

    onClicked: Launch.app(Commands.mouseSettings)

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
