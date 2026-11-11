pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config
import qs.core.enums
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

    StyledText {
        Layout.fillWidth: true

        text: root.config.labelBarWidgets
        color: Colours.textMuted
        wrapMode: Text.WordWrap
    }

    GridLayout {
        Layout.fillWidth: true

        columns: root.config.barWidgetColumns
        columnSpacing: root.config.cardSpacing * 2
        rowSpacing: 0

        Repeater {
            model: Appearance.bar.entryLabels

            SettingRow {
                id: widget

                required property var modelData

                readonly property bool locked: Appearance.bar.lockedEntries.includes(widget.modelData[0])

                label: widget.modelData[1]

                SegmentBar {
                    width: root.config.zoneSegmentWidth

                    options: BarZone.options
                    current: Prefs.barZone(widget.modelData[0])

                    onSelected: key => Prefs.setBarZone(widget.modelData[0], key)
                }

                Toggle {
                    enabled: !widget.locked
                    checked: Prefs.barEnabled(widget.modelData[0])

                    onToggled: checked => Prefs.setBarEnabled(widget.modelData[0], checked)
                }
            }
        }
    }
}
