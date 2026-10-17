pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.core.config
import qs.core.helpers
import qs.services

ColumnLayout {
    id: root

    readonly property real powerFraction: GpuStats.powerCap > 0 ? GpuStats.power / GpuStats.powerCap : 0

    function mb(bytes: real): int {
        return Math.round(bytes / Appearance.hardware.bytesPerMb);
    }

    Layout.fillWidth: true

    spacing: Appearance.hardware.blockSpacing

    SectionTitle {
        glyph: Icons.gpu
        title: Appearance.hardware.titleTemplate.arg(Appearance.hardware.labelGpu).arg(GpuStats.name)
        accent: Colours.gpu
    }

    ColumnLayout {
        Layout.fillWidth: true

        spacing: Appearance.spacing.none

        StatRow {
            glyph: Icons.thermometer
            label: Appearance.hardware.labelTemp
            value: Appearance.hardware.tempTemplate.arg(Math.round(GpuStats.temp))
            valueColour: Tone.level(GpuStats.temp, Appearance.hardware.gpuTempWarning, Appearance.hardware.gpuTempCritical, Colours.text)
        }

        StatRow {
            glyph: Icons.memory
            label: Appearance.hardware.labelVram
            value: Appearance.hardware.vramTemplate.arg(root.mb(GpuStats.vramUsed)).arg(root.mb(GpuStats.vramTotal))
            valueColour: Tone.usage(GpuStats.vramFraction * Appearance.scale.percent, Colours.text)
        }

        StatRow {
            glyph: Icons.flash
            label: Appearance.hardware.labelPower
            value: Appearance.hardware.powerCapTemplate.arg(GpuStats.power.toFixed(Appearance.hardware.powerPrecision)).arg(Math.round(GpuStats.powerCap))
            valueColour: Tone.usage(root.powerFraction * Appearance.scale.percent, Colours.text)
        }

        StatRow {
            glyph: Icons.speedometer
            label: Appearance.hardware.labelUtil
            value: Appearance.scale.percentTemplate.arg(GpuStats.busyPercent)
            valueColour: Tone.usage(GpuStats.busyPercent, Colours.text)
        }

        StatRow {
            glyph: Icons.fan
            label: Appearance.hardware.labelFan
            value: Appearance.hardware.fanTemplate.arg(Math.round(GpuStats.fan * Appearance.scale.percent)).arg(Math.round(GpuStats.fanRpm))
            valueColour: Tone.usage(GpuStats.fan * Appearance.scale.percent, Colours.text)
        }

        StatRow {
            glyph: Icons.timer
            label: Appearance.hardware.labelClock
            value: Appearance.hardware.mhzTemplate.arg(Math.round(GpuStats.clockMhz))
            valueColour: Colours.gpu
        }
    }

    GpuDie {
        Layout.fillWidth: true
    }

    ListBlock {
        title: Appearance.hardware.labelTopGpuProcs
        placeholder: Appearance.hardware.emptyGpuProcs
        empty: GpuStats.processes.length === 0

        Repeater {
            model: GpuStats.processes

            ProcRow {
                required property var modelData

                readonly property int percent: Math.round(modelData.busy * Appearance.scale.percent)

                name: modelData.name
                glyph: Icons.speedometer
                value: Appearance.scale.percentTemplate.arg(percent)
                valueColour: Tone.usage(percent, Colours.gpu)
                extraGlyph: Icons.memory
                extra: Appearance.hardware.mbTemplate.arg(Math.round(modelData.vramKb / Appearance.hardware.kbPerMb))
            }
        }
    }
}
