pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.core.config
import qs.core.helpers
import qs.services

ColumnLayout {
    id: root

    readonly property real total: Math.max(1, SysInfo.memTotalKb)
    readonly property real cached: SysInfo.memCachedKb / root.total
    readonly property real buffers: SysInfo.memBuffersKb / root.total
    readonly property real free: SysInfo.memFreeKb / root.total
    readonly property real used: Math.max(0, 1 - root.cached - root.buffers - root.free)

    readonly property var segments: [
        {
            label: Appearance.hardware.labelUsed,
            fraction: root.used,
            colour: Colours.memory
        },
        {
            label: Appearance.hardware.labelCached,
            fraction: root.cached,
            colour: Colours.memoryCached
        },
        {
            label: Appearance.hardware.labelBuffers,
            fraction: root.buffers,
            colour: Colours.memoryBuffers
        },
        {
            label: Appearance.hardware.labelFree,
            fraction: root.free,
            colour: Colours.trough
        }
    ]

    Layout.fillWidth: true

    spacing: Appearance.hardware.blockSpacing

    SectionTitle {
        glyph: Icons.memory
        title: Appearance.hardware.labelMemory
        accent: Colours.memory
    }

    ColumnLayout {
        Layout.fillWidth: true

        spacing: Appearance.spacing.none

        StatRow {
            glyph: Icons.memory
            label: Appearance.hardware.labelUsage
            value: Appearance.hardware.usageTemplate.arg(Fmt.gbFromKb(SysInfo.memUsedKb)).arg(Fmt.gbFromKb(SysInfo.memTotalKb))
            valueColour: Tone.usage(SysInfo.memPercent, Colours.memory)
        }

        StatRow {
            glyph: Icons.speedometer
            label: Appearance.hardware.labelUtil
            value: Appearance.scale.percentTemplate.arg(SysInfo.memPercent)
            valueColour: Tone.usage(SysInfo.memPercent, Colours.text)
        }

        StatRow {
            visible: SysInfo.swapTotalKb > 0
            glyph: Icons.harddisk
            label: Appearance.hardware.labelSwap
            value: Appearance.hardware.usageTemplate.arg(Fmt.gbFromKb(SysInfo.swapUsedKb)).arg(Fmt.gbFromKb(SysInfo.swapTotalKb))
            valueColour: Colours.swap
        }
    }

    ListBlock {
        title: Appearance.hardware.labelModules
        placeholder: Appearance.hardware.emptyDimms
        empty: Dimms.modules.length === 0

        Repeater {
            model: Dimms.modules

            StatRow {
                required property var modelData

                glyph: Icons.memory
                value: [modelData.locator, modelData.size, modelData.type, modelData.speed].join(Appearance.hardware.fieldSeparator)
            }
        }
    }

    DimmStick {
        Layout.fillWidth: true

        segments: root.segments
    }

    RowLayout {
        Layout.fillWidth: true

        spacing: Appearance.hardware.legendGap

        Repeater {
            model: root.segments

            LegendItem {
                required property var modelData

                colour: modelData.colour
                label: Appearance.hardware.legendTemplate.arg(modelData.label).arg((modelData.fraction * Appearance.scale.percent).toFixed(Appearance.hardware.legendPrecision))
            }
        }
    }
}
