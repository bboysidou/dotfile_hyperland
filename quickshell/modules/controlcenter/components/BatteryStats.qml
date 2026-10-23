pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config
import qs.core.helpers
import qs.services

StyledRect {
    id: root

    readonly property var config: Appearance.powerPanel

    readonly property var stats: [
        {
            label: Battery.charging ? root.config.statInput : root.config.statDraw,
            value: root.config.wattTemplate.arg(root.fixed(Battery.rate))
        },
        {
            label: root.config.statEnergy,
            value: Battery.capacity > 0 ? root.config.energyTemplate.arg(root.fixed(Battery.energy)).arg(root.fixed(Battery.capacity)) : ""
        },
        {
            label: root.config.statHealth,
            value: Battery.health > 0 ? (Battery.design > 0 ? root.config.healthTemplate.arg(Math.round(Battery.health)).arg(root.fixed(Battery.design)) : root.config.percentTemplate.arg(Math.round(Battery.health))) : ""
        },
        {
            label: root.config.statRuntime,
            value: Battery.runtime > 0 ? Fmt.uptime(Battery.runtime) : ""
        },
        {
            label: root.config.statCycles,
            value: Battery.cycles > 0 ? String(Battery.cycles) : ""
        },
        {
            label: root.config.statVoltage,
            value: Battery.voltage > 0 ? root.config.voltTemplate.arg(root.fixed(Battery.voltage)) : ""
        },
        {
            label: root.config.statTemperature,
            value: isFinite(Battery.temperature) ? root.config.celsiusTemplate.arg(root.fixed(Battery.temperature)) : ""
        },
        {
            label: root.config.statLimit,
            value: Battery.limit > 0 && Battery.limit < Appearance.scale.percent ? root.config.percentTemplate.arg(Battery.limit) : ""
        },
        {
            label: root.config.statCell,
            value: Battery.cell
        }
    ].filter(entry => entry.value !== "")

    function fixed(value: real): string {
        return Number(value).toFixed(root.config.statDecimals);
    }

    Layout.fillWidth: true
    Layout.preferredHeight: grid.implicitHeight + root.config.sliderCardPadding * 2

    radius: root.config.cardRounding
    color: Colours.elevated

    GridLayout {
        id: grid

        anchors.fill: parent
        anchors.margins: root.config.sliderCardPadding

        columns: root.config.statColumns
        columnSpacing: root.config.statSpacing
        rowSpacing: root.config.statSpacing

        Repeater {
            model: root.stats

            ColumnLayout {
                id: stat

                required property var modelData

                Layout.fillWidth: true
                Layout.preferredWidth: 1

                spacing: 0

                StyledText {
                    Layout.fillWidth: true

                    text: stat.modelData.label
                    color: Colours.textMuted
                    font.pixelSize: root.config.statLabelSize
                    font.letterSpacing: root.config.statLetterSpacing
                    elide: Text.ElideRight
                }

                StyledText {
                    Layout.fillWidth: true

                    text: stat.modelData.value
                    color: Colours.textBright
                    font.pixelSize: root.config.statValueSize
                    font.family: Appearance.font.family.mono
                    elide: Text.ElideRight
                }
            }
        }
    }
}
