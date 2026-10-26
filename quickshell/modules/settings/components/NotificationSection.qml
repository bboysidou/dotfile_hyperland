pragma ComponentBehavior: Bound

import QtQuick
import qs.core.config
import qs.core.constants
import qs.modules.display.components
import qs.services

SettingsSection {
    id: root

    readonly property var config: Appearance.settings

    title: root.config.labelNotifications
    glyph: Icons.notifNormal

    Repeater {
        model: root.config.urgencyLabels

        SettingRow {
            id: row

            required property var modelData

            readonly property int urgency: row.modelData[0]
            readonly property int timeout: Prefs.notifTimeouts[row.urgency]

            label: row.modelData[1]

            Stepper {
                stepperWidth: root.config.stepperWidth
                value: row.timeout > 0 ? root.config.secondsTemplate.arg(Math.round(row.timeout / Units.msPerSecond)) : root.config.labelNever
                canDecrease: row.timeout > root.config.timeoutMin
                canIncrease: row.timeout < root.config.timeoutMax

                onStepped: delta => Prefs.stepTimeout(row.urgency, delta)
            }
        }
    }

    SettingRow {
        label: root.config.labelMaxPopups

        Stepper {
            stepperWidth: root.config.stepperWidth
            value: String(Prefs.maxPopups)
            canDecrease: Prefs.maxPopups > root.config.popupsMin
            canIncrease: Prefs.maxPopups < root.config.popupsMax

            onStepped: delta => Prefs.stepValue("maxPopups", delta, root.config.countStep, root.config.popupsMin, root.config.popupsMax)
        }
    }

    SettingRow {
        label: root.config.labelHistoryDays

        Stepper {
            stepperWidth: root.config.stepperWidth
            value: root.config.daysTemplate.arg(Prefs.historyDays)
            canDecrease: Prefs.historyDays > root.config.historyDaysMin
            canIncrease: Prefs.historyDays < root.config.historyDaysMax

            onStepped: delta => Prefs.stepValue("historyDays", delta, root.config.countStep, root.config.historyDaysMin, root.config.historyDaysMax)
        }
    }

    SettingRow {
        label: root.config.labelHistoryMax

        Stepper {
            stepperWidth: root.config.stepperWidth
            value: String(Prefs.historyMax)
            canDecrease: Prefs.historyMax > root.config.historyMaxMin
            canIncrease: Prefs.historyMax < root.config.historyMaxMax

            onStepped: delta => Prefs.stepValue("historyMax", delta, root.config.historyMaxStep, root.config.historyMaxMin, root.config.historyMaxMax)
        }
    }
}
