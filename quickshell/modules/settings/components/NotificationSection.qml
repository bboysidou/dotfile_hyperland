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
}
