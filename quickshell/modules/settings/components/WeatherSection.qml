import QtQuick
import qs.core.config
import qs.core.enums
import qs.core.components
import qs.services

SettingsSection {
    id: root

    readonly property var config: Appearance.settings

    title: root.config.labelWeather
    glyph: Icons.weatherPartly

    SettingRow {
        label: root.config.labelTempUnit

        SegmentBar {
            width: root.config.segmentWidth

            options: TempUnit.values.map(unit => ({
                        key: unit,
                        label: TempUnit.labels[unit]
                    }))
            current: Prefs.tempUnit

            onSelected: key => Prefs.set("tempUnit", key)
        }
    }

    SettingRow {
        label: root.config.labelWindUnit

        SegmentBar {
            width: root.config.segmentWidth

            options: WindUnit.values.map(unit => ({
                        key: unit,
                        label: WindUnit.labels[unit]
                    }))
            current: Prefs.windUnit

            onSelected: key => Prefs.set("windUnit", key)
        }
    }
}
