pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config
import qs.core.helpers
import qs.services

ColumnLayout {
    id: root

    readonly property real powerFraction: GpuStats.powerFraction

    function mb(bytes: real): int {
        return Math.round(bytes / Appearance.hardware.bytesPerMb);
    }

    function shown(value: real, text: string): string {
        return isFinite(value) ? text : Appearance.hardware.placeholder;
    }

    function power(): string {
        const config = Appearance.hardware;
        const watts = GpuStats.power.toFixed(config.powerPrecision);

        if (!isFinite(GpuStats.power))
            return config.placeholder;

        return GpuStats.powerCap > 0 ? config.powerCapTemplate.arg(watts).arg(Math.round(GpuStats.powerCap)) : config.powerTemplate.arg(watts);
    }

    function vram(): string {
        const config = Appearance.hardware;

        if (isFinite(GpuStats.vramTotal))
            return root.shown(GpuStats.vramUsed, config.vramTemplate.arg(root.mb(GpuStats.vramUsed)).arg(root.mb(GpuStats.vramTotal)));

        return root.shown(GpuStats.vramUsed, config.mbTemplate.arg(root.mb(GpuStats.vramUsed)));
    }

    function fan(): string {
        const config = Appearance.hardware;

        if (!isFinite(GpuStats.fan) && !isFinite(GpuStats.fanRpm))
            return config.placeholder;

        return config.fanTemplate.arg(root.shown(GpuStats.fan, String(Math.round(GpuStats.fan * Appearance.scale.percent)))).arg(root.shown(GpuStats.fanRpm, String(Math.round(GpuStats.fanRpm))));
    }

    Layout.fillWidth: true

    spacing: Appearance.hardware.blockSpacing

    SegmentBar {
        Layout.fillWidth: true

        visible: GpuStats.cards.length > 1
        current: String(GpuStats.selected)
        accent: Colours.gpu
        options: GpuStats.cards.map((card, index) => ({
                    key: String(index),
                    label: card.dedicated ? Appearance.hardware.labelDedicated : Appearance.hardware.labelIntegrated
                }))

        onSelected: key => GpuStats.select(Number(key))
    }

    SectionTitle {
        glyph: Icons.gpu
        title: Appearance.hardware.titleTemplate.arg(Appearance.hardware.labelGpu).arg(GpuStats.name)
        accent: Colours.gpu
    }

    ColumnLayout {
        Layout.fillWidth: true

        spacing: Appearance.spacing.none

        StatRow {
            visible: GpuStats.suspended
            glyph: Icons.flash
            label: Appearance.hardware.labelState
            value: Appearance.hardware.stateSuspended
            valueColour: Colours.textMuted
        }

        StatRow {
            visible: GpuStats.missing.length > 0
            glyph: Icons.download
            label: Appearance.hardware.labelDriver
            value: Appearance.hardware.missingTemplate.arg(GpuStats.missing)
            valueColour: Colours.warning
        }

        StatRow {
            glyph: Icons.thermometer
            label: Appearance.hardware.labelTemp
            value: root.shown(GpuStats.temp, Appearance.hardware.tempTemplate.arg(Math.round(GpuStats.temp)))
            valueColour: Tone.level(GpuStats.temp, Appearance.hardware.gpuTempWarning, Appearance.hardware.gpuTempCritical, Colours.text)
        }

        StatRow {
            glyph: Icons.memory
            label: Appearance.hardware.labelVram
            value: root.vram()
            valueColour: Tone.usage(GpuStats.vramFraction * Appearance.scale.percent, Colours.text)
        }

        StatRow {
            glyph: Icons.flash
            label: Appearance.hardware.labelPower
            value: root.power()
            valueColour: Tone.usage(root.powerFraction * Appearance.scale.percent, Colours.text)
        }

        StatRow {
            glyph: Icons.speedometer
            label: Appearance.hardware.labelUtil
            value: root.shown(GpuStats.busy, Appearance.scale.percentTemplate.arg(GpuStats.busyPercent))
            valueColour: Tone.usage(GpuStats.busyPercent, Colours.text)
        }

        StatRow {
            glyph: Icons.fan
            label: Appearance.hardware.labelFan
            value: root.fan()
            valueColour: Tone.usage(GpuStats.fan * Appearance.scale.percent, Colours.text)
        }

        StatRow {
            glyph: Icons.timer
            label: Appearance.hardware.labelClock
            value: root.shown(GpuStats.clockMhz, Appearance.hardware.mhzTemplate.arg(Math.round(GpuStats.clockMhz)))
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
