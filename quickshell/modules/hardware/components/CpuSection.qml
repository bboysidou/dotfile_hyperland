pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.core.config
import qs.core.helpers
import qs.services

ColumnLayout {
    id: root

    function ghz(mhz: real): string {
        return (mhz / Appearance.hardware.mhzPerGhz).toFixed(Appearance.hardware.clockPrecision);
    }

    function share(percent: real): string {
        const config = Appearance.hardware;
        const cores = Math.max(1, Math.ceil(percent / Appearance.scale.percent));
        const rounded = Math.round(percent);

        return cores > 1 ? config.coresTemplate.arg(rounded).arg(cores) : config.coreTemplateSingle.arg(rounded);
    }

    Layout.fillWidth: true

    spacing: Appearance.hardware.blockSpacing

    SectionTitle {
        glyph: Icons.cpu
        title: Appearance.hardware.titleTemplate.arg(Appearance.hardware.labelCpu).arg(SysInfo.cpuName)
        accent: Colours.cpu
    }

    ColumnLayout {
        Layout.fillWidth: true

        spacing: Appearance.spacing.none

        StatRow {
            glyph: Icons.timer
            label: Appearance.hardware.labelClock
            value: Appearance.hardware.clockTemplate.arg(root.ghz(CpuStats.clockMhz)).arg(root.ghz(CpuStats.maxClockMhz))
            valueColour: Colours.cpu
        }

        StatRow {
            glyph: Icons.thermometer
            label: Appearance.hardware.labelTemp
            value: Appearance.hardware.tempTemplate.arg(Math.round(CpuStats.temp))
            valueColour: Tone.level(CpuStats.temp, Appearance.hardware.cpuTempWarning, Appearance.hardware.cpuTempCritical, Colours.text)
        }

        StatRow {
            glyph: Icons.flash
            label: Appearance.hardware.labelPower
            value: CpuStats.power >= 0 ? Appearance.hardware.powerTemplate.arg(CpuStats.power) : Appearance.hardware.placeholder
            valueColour: CpuStats.power >= 0 ? Colours.text : Colours.textMuted
        }

        StatRow {
            glyph: Icons.speedometer
            label: Appearance.hardware.labelUtil
            value: Appearance.scale.percentTemplate.arg(CpuStats.usagePercent)
            valueColour: Tone.usage(CpuStats.usagePercent, Colours.text)
        }
    }

    CpuDie {
        Layout.fillWidth: true
    }

    ListBlock {
        title: Appearance.hardware.labelActiveCores

        Repeater {
            model: CpuStats.busiestCores

            ProcRow {
                required property var modelData

                readonly property real percent: modelData.value * Appearance.scale.percent

                name: Appearance.hardware.coreTemplate.arg(String(modelData.index + 1).padStart(Appearance.hardware.corePadding, "0"))
                glyph: Icons.cpu
                value: Appearance.hardware.coreUsedTemplate.arg(percent.toFixed(Appearance.hardware.legendPrecision))
                valueColour: Tone.usage(percent, Colours.cpu)
            }
        }
    }

    ListBlock {
        title: Appearance.hardware.labelTopProcs
        placeholder: Appearance.hardware.placeholder
        empty: CpuStats.processes.length === 0

        Repeater {
            model: CpuStats.processes

            ProcRow {
                required property var modelData

                name: modelData.name
                glyph: Icons.cpu
                value: root.share(modelData.percent)
                valueColour: Tone.usage(modelData.percent, Colours.cpu)
            }
        }
    }
}
