pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config
import qs.core.enums
import qs.modules.controlcenter
import qs.modules.controlcenter.components
import qs.modules.power
import qs.services

Panel {
    id: root

    readonly property var config: Appearance.powerPanel
    readonly property var tabs: [
        {
            key: PowerSection.overview,
            icon: Icons.power,
            label: Appearance.batteryTab.labelOverview,
            accent: Colours.tabOverview
        },
        {
            key: PowerSection.history,
            icon: Icons.timer,
            label: Appearance.batteryTab.labelHistory,
            accent: Colours.tabHistory
        },
        {
            key: PowerSection.details,
            icon: Icons.hardware,
            label: Appearance.batteryTab.labelDetails,
            accent: Colours.tabDetails
        },
        {
            key: PowerSection.care,
            icon: Icons.leaf,
            label: Appearance.batteryTab.labelCare,
            accent: Colours.tabCare
        }
    ].filter(tab => tab.key !== PowerSection.care || BatteryCare.supported)
    readonly property string section: Battery.available && root.tabs.some(tab => tab.key === ControlState.powerSection) ? ControlState.powerSection : PowerSection.overview

    function run(action: string): void {
        ControlState.hide();
        PowerState.run(action);
    }

    outlineColour: tabBar.fill
    implicitWidth: Appearance.orbit.panelWidth

    ColumnLayout {
        anchors.fill: parent

        spacing: root.config.sectionSpacing

        RowLayout {
            Layout.fillWidth: true

            StyledText {
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

        SegmentBar {
            id: tabBar

            Layout.fillWidth: true

            visible: Battery.available
            current: root.section
            options: root.tabs

            onSelected: key => ControlState.powerSection = key
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

                HistoryCard {
                    accent: Colours.tabHistory
                }

                PowerSplit {
                    accent: Colours.tabHistory
                }

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

                CareCard {
                    accent: Colours.tabCare
                }

                Item {
                    Layout.fillHeight: true
                }
            }
        }
    }
}
