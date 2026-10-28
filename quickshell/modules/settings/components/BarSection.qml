import QtQuick
import qs.core.components
import qs.core.config
import qs.services

SettingsSection {
    id: root

    title: Appearance.settings.labelBar
    glyph: Icons.dashTab

    SettingRow {
        label: Appearance.settings.labelBarClock

        SegmentBar {
            width: Appearance.settings.segmentWidth

            options: Appearance.settings.barClockFormats
            current: Prefs.barClock

            onSelected: key => Prefs.set("barClock", key)
        }
    }
}
