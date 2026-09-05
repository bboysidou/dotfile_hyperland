import QtQuick
import QtQuick.Layouts
import QtQml.Models
import qs.core.config
import qs.core.enums
import qs.modules.bar.components

RowLayout {
    id: root

    property var entries: []
    property var panelWindow: null
    property real mediaBudget: 0

    spacing: Appearance.spacing.none

    Repeater {
        model: root.entries

        DelegateChooser {
            role: "modelData"

            DelegateChoice {
                roleValue: BarEntry.osIcon

                delegate: OsIcon {}
            }
            DelegateChoice {
                roleValue: BarEntry.workspaces

                delegate: Workspaces {}
            }
            DelegateChoice {
                roleValue: BarEntry.updates

                delegate: UpdatesPill {}
            }
            DelegateChoice {
                roleValue: BarEntry.media

                delegate: MediaPill {
                    budget: root.mediaBudget
                }
            }
            DelegateChoice {
                roleValue: BarEntry.worldClock

                delegate: WorldClock {}
            }
            DelegateChoice {
                roleValue: BarEntry.volume

                delegate: VolumePill {}
            }
            DelegateChoice {
                roleValue: BarEntry.mouseBattery

                delegate: MouseBatteryPill {}
            }
            DelegateChoice {
                roleValue: BarEntry.bluetooth

                delegate: BluetoothPill {}
            }
            DelegateChoice {
                roleValue: BarEntry.network

                delegate: NetworkPill {}
            }
            DelegateChoice {
                roleValue: BarEntry.notifications

                delegate: NotifPill {}
            }
            DelegateChoice {
                roleValue: BarEntry.tray

                delegate: Tray {
                    panel: root.panelWindow
                }
            }
            DelegateChoice {
                roleValue: BarEntry.cpu

                delegate: CpuPill {}
            }
            DelegateChoice {
                roleValue: BarEntry.memory

                delegate: MemoryPill {}
            }
        }
    }
}
