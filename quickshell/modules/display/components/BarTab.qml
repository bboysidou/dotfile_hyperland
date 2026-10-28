pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config
import qs.core.enums
import qs.modules.display
import qs.services

ColumnLayout {
    id: root

    property color accent: Colours.accent

    readonly property var config: Appearance.display
    readonly property var bar: Prefs.barOf(DisplayState.monitor)

    spacing: 0

    StyledText {
        Layout.fillWidth: true
        Layout.bottomMargin: root.config.gridSpacing

        text: root.config.labelBarHint.arg(DisplayState.monitor)
        color: Colours.textMuted
    }

    OptionRow {
        label: root.config.labelBarShown

        Toggle {
            accent: root.accent
            checked: root.bar.shown

            onToggled: checked => Prefs.setBar(DisplayState.monitor, "shown", checked)
        }
    }

    OptionRow {
        visible: !root.bar.shown
        label: root.config.labelBarFrame

        Toggle {
            accent: root.accent
            checked: root.bar.frame

            onToggled: checked => Prefs.setBar(DisplayState.monitor, "frame", checked)
        }
    }

    OptionRow {
        label: root.config.labelBarEdge

        SegmentBar {
            width: root.config.barEdgeWidth

            accent: root.accent
            enabled: root.bar.shown
            opacity: root.bar.shown ? 1 : root.config.disabledOpacity
            options: BarEdge.values.map(edge => ({
                        key: edge,
                        label: BarEdge.labels[edge]
                    }))
            current: root.bar.edge

            onSelected: key => Prefs.setBar(DisplayState.monitor, "edge", key)
        }
    }

    GridLayout {
        Layout.fillWidth: true
        Layout.topMargin: root.config.gridSpacing

        enabled: root.bar.shown
        opacity: root.bar.shown ? 1 : root.config.disabledOpacity
        columns: root.config.barEntryColumns
        columnSpacing: root.config.gridSpacing * 2
        rowSpacing: 0

        Repeater {
            model: Appearance.bar.entryLabels

            OptionRow {
                id: entry

                required property var modelData

                label: entry.modelData[1]

                Toggle {
                    accent: root.accent
                    checked: !root.bar.hidden.includes(entry.modelData[0])

                    onToggled: checked => Prefs.setBarEntry(DisplayState.monitor, entry.modelData[0], checked)
                }
            }
        }
    }

    Item {
        Layout.fillHeight: true
    }
}
