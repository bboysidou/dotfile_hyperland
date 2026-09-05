import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config
import qs.core.helpers
import qs.modules.dashboard.components
import qs.services

ColumnLayout {
    id: root

    readonly property var disk: SysInfo.storage.length > 0 ? SysInfo.storage[0] : null
    readonly property real memFraction: SysInfo.memTotalKb > 0 ? SysInfo.memUsedKb / SysInfo.memTotalKb : 0

    spacing: Appearance.dash.spacing

    Card {
        Layout.fillWidth: true

        implicitWidth: hardware.implicitWidth + Appearance.dash.cardPadding * 2
        implicitHeight: hardware.implicitHeight + Appearance.dash.cardPadding * 2

        ColumnLayout {
            id: hardware

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: Appearance.dash.cardPadding

            spacing: Appearance.dash.cardSpacing

            CardLabel {
                Layout.fillWidth: true

                icon: Icons.perfTab
                label: Appearance.dash.labelHardware
            }

            RowLayout {
                Layout.alignment: Qt.AlignHCenter

                spacing: Appearance.dash.gaugeSpacing

                Gauge {
                    Layout.alignment: Qt.AlignVCenter

                    size: Appearance.dash.gaugeSizeSide
                    value: root.memFraction
                    secondaryValue: SysInfo.memPercent / Appearance.scale.percent
                    primary: Fmt.gbFromKb(SysInfo.memUsedKb)
                    label: Appearance.dash.labelMemory
                    secondary: Appearance.scale.percentTemplate.arg(SysInfo.memPercent)
                    secondaryLabel: Appearance.dash.labelUsage
                    colour: Colours.memory
                }

                Gauge {
                    Layout.alignment: Qt.AlignVCenter

                    size: Appearance.dash.gaugeSizeMain
                    value: Num.clamp(SysInfo.cpuTemp / Appearance.dash.cpuTempMax, 0, 1)
                    secondaryValue: SysInfo.cpuPercent / Appearance.scale.percent
                    primary: SysInfo.cpuTemp > 0 ? Appearance.dash.tempTemplate.arg(Math.round(SysInfo.cpuTemp)) : Appearance.dash.labelNoTemp
                    label: Appearance.dash.labelCpuTemp
                    secondary: Appearance.scale.percentTemplate.arg(SysInfo.cpuPercent)
                    secondaryLabel: Appearance.dash.labelUsage
                    colour: Colours.cpu
                }

                Gauge {
                    Layout.alignment: Qt.AlignVCenter

                    size: Appearance.dash.gaugeSizeSide
                    value: root.disk?.fraction ?? 0
                    secondaryValue: root.disk?.fraction ?? 0
                    primary: root.disk ? Fmt.gb(root.disk.size) : Appearance.dash.labelNoTemp
                    label: Appearance.dash.labelStorage
                    secondary: root.disk ? Fmt.gb(root.disk.used) : ""
                    secondaryLabel: root.disk ? Appearance.dash.labelUsed : ""
                    colour: Colours.storage
                }
            }
        }
    }

    Card {
        Layout.fillWidth: true

        implicitWidth: netLayout.implicitWidth + Appearance.dash.cardPadding * 2
        implicitHeight: netLayout.implicitHeight + Appearance.dash.cardPadding * 2

        ColumnLayout {
            id: netLayout

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: Appearance.dash.cardPadding

            spacing: Appearance.dash.cardSpacing

            CardLabel {
                Layout.fillWidth: true

                icon: Net.glyph
                label: Appearance.dash.labelNetwork
            }

            NetworkCard {
                Layout.fillWidth: true
            }
        }
    }
}
