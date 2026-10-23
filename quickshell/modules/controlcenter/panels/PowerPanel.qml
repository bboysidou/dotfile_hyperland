pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config
import qs.core.enums
import qs.core.helpers
import qs.modules.controlcenter
import qs.modules.controlcenter.components
import qs.modules.power
import qs.services

Panel {
    id: root

    readonly property var config: Appearance.powerPanel
    readonly property var tabs: [
        {
            section: PowerSection.overview,
            icon: Icons.power,
            label: Appearance.batteryTab.labelOverview
        },
        {
            section: PowerSection.battery,
            icon: Glyphs.batteryRamp(Battery.percent, Battery.charging),
            label: Appearance.batteryTab.labelBattery
        },
        {
            section: PowerSection.history,
            icon: Icons.timer,
            label: Appearance.batteryTab.labelHistory
        },
        {
            section: PowerSection.details,
            icon: Icons.hardware,
            label: Appearance.batteryTab.labelDetails
        },
        {
            section: PowerSection.care,
            icon: Icons.leaf,
            label: Appearance.batteryTab.labelCare
        }
    ].filter(tab => tab.section !== PowerSection.care || BatteryCare.supported)
    readonly property string section: Battery.available && root.tabs.some(tab => tab.section === ControlState.powerSection) ? ControlState.powerSection : PowerSection.overview

    function run(action: string): void {
        ControlState.hide();
        PowerState.run(action);
    }

    implicitWidth: Appearance.orbit.panelWidth

    ColumnLayout {
        anchors.fill: parent

        spacing: root.config.sectionSpacing

        RowLayout {
            Layout.fillWidth: true

            TimeLeft {
                visible: Battery.available
                seconds: Battery.secondsLeft
            }

            StyledText {
                visible: !Battery.available
                text: root.config.labelTitle
                color: Colours.textBright
            }

            Item {
                Layout.fillWidth: true
            }

            IconButton {
                icon: Icons.logout
                size: Appearance.control.scanIconSize

                onTriggered: root.run(PowerAction.logout)
            }
        }

        TabStrip {
            Layout.alignment: Qt.AlignHCenter

            visible: Battery.available
            current: root.section
            tabs: root.tabs

            onSelected: section => ControlState.powerSection = section
        }

        StackLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true

            currentIndex: PowerSection.values.indexOf(root.section)

            PowerOverview {
                onTriggered: action => root.run(action)
            }

            ColumnLayout {
                spacing: Appearance.batteryTab.sectionSpacing

                HealthChips {}

                BatteryStats {
                    essential: true
                }

                ChargerCard {}

                Item {
                    Layout.fillHeight: true
                }
            }

            ColumnLayout {
                spacing: Appearance.batteryTab.sectionSpacing

                HistoryCard {}

                PowerSplit {}

                Item {
                    Layout.fillHeight: true
                }
            }

            ColumnLayout {
                spacing: Appearance.batteryTab.sectionSpacing

                BatteryStats {}

                Item {
                    Layout.fillHeight: true
                }
            }

            ColumnLayout {
                spacing: Appearance.batteryTab.sectionSpacing

                CareCard {}

                Item {
                    Layout.fillHeight: true
                }
            }
        }
    }
}
