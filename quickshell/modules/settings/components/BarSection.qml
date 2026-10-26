pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config
import qs.services

SettingsSection {
    id: root

    title: Appearance.settings.labelBar
    glyph: Icons.dashTab

    GridLayout {
        Layout.fillWidth: true

        columns: 2
        columnSpacing: Appearance.settings.listSpacing * 2
        rowSpacing: 0

        Repeater {
            model: Appearance.settings.barLabels

            SettingRow {
                required property var modelData

                label: modelData[1]

                Toggle {
                    checked: Prefs.shown(modelData[0])

                    onToggled: checked => Prefs.setShown(modelData[0], checked)
                }
            }
        }
    }
}
