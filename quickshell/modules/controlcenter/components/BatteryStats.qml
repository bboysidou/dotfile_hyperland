pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Services.UPower
import qs.core.components
import qs.core.config
import qs.core.helpers
import qs.services

StyledRect {
    id: root

    property bool essential: false

    readonly property var config: Appearance.powerPanel

    readonly property var stats: [
        {
            label: Battery.charging ? root.config.statInput : root.config.statDraw,
            essential: true,
            value: root.config.wattTemplate.arg(root.fixed(Battery.rate))
        },
        {
            label: root.config.statEnergy,
            essential: true,
            value: Battery.capacity > 0 ? root.config.energyTemplate.arg(root.fixed(Battery.energy)).arg(root.fixed(Battery.capacity)) : ""
        },
        {
            label: root.config.statHealth,
            essential: true,
            value: Battery.health > 0 ? (Battery.design > 0 ? root.config.healthTemplate.arg(Math.round(Battery.health)).arg(root.fixed(Battery.design)) : root.config.percentTemplate.arg(Math.round(Battery.health))) : ""
        },
        {
            label: root.config.statRuntime,
            essential: true,
            value: Battery.runtime > 0 ? Fmt.uptime(Battery.runtime) : ""
        },
        {
            label: Battery.state === UPowerDeviceState.Charging ? root.config.statTimeToFull : root.config.statTimeLeft,
            essential: true,
            value: Battery.secondsLeft > 0 ? Fmt.uptime(Battery.secondsLeft) : ""
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
            label: root.config.statCurrent,
            value: Battery.current > 0 ? root.config.ampTemplate.arg(root.fixed(Battery.current)) : ""
        },
        {
            label: root.config.statVendorHealth,
            value: Battery.vendorHealth > 0 ? root.config.percentTemplate.arg(Battery.vendorHealth) : ""
        },
        {
            label: root.config.statResistance,
            value: Battery.resistance > 0 ? root.config.milliOhmTemplate.arg(root.fixed(Battery.resistance)) : ""
        },
        {
            label: root.config.statLimit,
            value: Battery.limit > 0 && Battery.limit < Appearance.scale.percent ? (Battery.startLimit > 0 ? root.config.limitRangeTemplate.arg(Battery.startLimit).arg(Battery.limit) : root.config.percentTemplate.arg(Battery.limit)) : ""
        },
        {
            label: root.config.statCell,
            value: Battery.cell
        },
        {
            label: root.config.statSerial,
            value: Battery.serial
        }
    ].filter(entry => entry.value !== "" && (entry.essential ?? false) === root.essential)

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

                ScrollText {
                    Layout.fillWidth: true

                    text: stat.modelData.label
                    color: Colours.textMuted
                    font.pixelSize: root.config.statLabelSize
                    font.letterSpacing: root.config.statLetterSpacing
                }

                ScrollText {
                    Layout.fillWidth: true

                    text: stat.modelData.value
                    color: Colours.textBright
                    font.pixelSize: root.essential ? root.config.statValueSizeLarge : root.config.statValueSize
                    font.family: Appearance.font.family.mono
                }
            }
        }
    }
}
