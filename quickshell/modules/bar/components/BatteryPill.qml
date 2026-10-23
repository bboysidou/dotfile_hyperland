import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config
import qs.core.enums
import qs.core.helpers
import qs.modules.controlcenter
import qs.services

Pill {
    id: root

    readonly property color stateColour: {
        if (Battery.charging)
            return Colours.text;
        if (Battery.percent < Appearance.powerPanel.criticalPercent)
            return Colours.critical;
        if (Battery.percent < Appearance.powerPanel.warningPercent)
            return Colours.warning;
        return Colours.text;
    }

    Layout.rightMargin: Appearance.bar.pillMarginRight

    visible: Battery.available
    interactive: true

    onClicked: ControlState.toggle(ControlSection.power)

    Icon {
        text: Glyphs.batteryRamp(Battery.percent, Battery.charging)
        color: root.stateColour
    }

    StyledText {
        text: Appearance.scale.percentTemplate.arg(Battery.percent)
        color: root.stateColour
    }
}
