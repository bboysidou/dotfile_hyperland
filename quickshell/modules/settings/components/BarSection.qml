pragma ComponentBehavior: Bound

import QtQuick
import qs.core.components
import qs.core.config
import qs.modules.barlayout
import qs.services

SettingsSection {
    id: root

    readonly property var config: Appearance.settings

    title: root.config.labelBar
    glyph: Icons.dashTab

    SettingRow {
        label: root.config.labelBarClock

        SegmentBar {
            width: root.config.segmentWidth

            options: root.config.barClockFormats
            current: Prefs.barClock

            onSelected: key => Prefs.set("barClock", key)
        }
    }

    SettingRow {
        label: root.config.labelBarWidgets

        PillButton {
            glyph: Icons.dashTab
            label: root.config.labelEditLayout

            onTriggered: BarLayoutState.show()
        }
    }
}
