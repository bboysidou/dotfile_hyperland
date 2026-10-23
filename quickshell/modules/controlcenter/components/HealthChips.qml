import QtQuick
import QtQuick.Layouts
import qs.core.config
import qs.core.constants
import qs.services

Flow {
    id: root

    readonly property var config: Appearance.batteryTab
    readonly property int years: Math.floor(Battery.ageMonths / Units.monthsPerYear)
    readonly property string age: {
        if (Battery.ageMonths < 0)
            return "";
        if (root.years > 0)
            return root.config.ageYearsTemplate.arg(root.years).arg(Battery.ageMonths % Units.monthsPerYear);
        return root.config.ageMonthsTemplate.arg(Battery.ageMonths);
    }
    readonly property bool good: Battery.condition === "" || Battery.condition === root.config.conditionGood
    readonly property bool calibrate: Battery.errorMargin >= root.config.calibrationMargin

    Layout.fillWidth: true

    visible: Battery.condition !== "" || root.age !== "" || root.calibrate
    spacing: root.config.chipSpacing

    StatusChip {
        visible: Battery.condition !== ""
        glyph: Icons.shield
        label: root.config.conditionTemplate.arg(Battery.condition)
        tone: root.good ? Colours.accent : Colours.critical
    }

    StatusChip {
        visible: root.age !== ""
        glyph: Icons.calendarMonth
        label: root.age
    }

    StatusChip {
        visible: root.calibrate
        glyph: Icons.refresh
        label: root.config.labelCalibrate
        tone: Colours.warning
    }
}
