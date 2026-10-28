import QtQuick
import QtQuick.Layouts
import QtQml.Models
import qs.core.config
import qs.core.enums
import qs.modules.bar.components

GridLayout {
    id: root

    property string edge: BarEdge.top
    property var entries: []
    property var panelWindow: null
    property real mediaBudget: 0

    flow: BarEdge.vertical(root.edge) ? GridLayout.TopToBottom : GridLayout.LeftToRight
    rows: BarEdge.vertical(root.edge) ? -1 : 1
    columns: BarEdge.vertical(root.edge) ? 1 : -1
    rowSpacing: Appearance.spacing.none
    columnSpacing: Appearance.spacing.none

    Repeater {
        model: root.entries

        DelegateChooser {
            role: "modelData"

            DelegateChoice {
                roleValue: BarEntry.osIcon

                delegate: OsIcon {
                    edge: root.edge
                }
            }
            DelegateChoice {
                roleValue: BarEntry.workspaces

                delegate: Workspaces {
                    edge: root.edge
                }
            }
            DelegateChoice {
                roleValue: BarEntry.updates

                delegate: UpdatesPill {
                    edge: root.edge
                }
            }
            DelegateChoice {
                roleValue: BarEntry.media

                delegate: MediaPill {
                    edge: root.edge
                    budget: root.mediaBudget
                }
            }
            DelegateChoice {
                roleValue: BarEntry.worldClock

                delegate: WorldClock {
                    edge: root.edge
                }
            }
            DelegateChoice {
                roleValue: BarEntry.prayers

                delegate: PrayerPill {
                    edge: root.edge
                }
            }
            DelegateChoice {
                roleValue: BarEntry.volume

                delegate: VolumePill {
                    edge: root.edge
                }
            }
            DelegateChoice {
                roleValue: BarEntry.mouseBattery

                delegate: MouseBatteryPill {
                    edge: root.edge
                }
            }
            DelegateChoice {
                roleValue: BarEntry.battery

                delegate: BatteryPill {
                    edge: root.edge
                }
            }
            DelegateChoice {
                roleValue: BarEntry.bluetooth

                delegate: BluetoothPill {
                    edge: root.edge
                }
            }
            DelegateChoice {
                roleValue: BarEntry.network

                delegate: NetworkPill {
                    edge: root.edge
                }
            }
            DelegateChoice {
                roleValue: BarEntry.notifications

                delegate: NotifPill {
                    edge: root.edge
                }
            }
            DelegateChoice {
                roleValue: BarEntry.tray

                delegate: Tray {
                    edge: root.edge
                    panel: root.panelWindow
                }
            }
            DelegateChoice {
                roleValue: BarEntry.cpu

                delegate: CpuPill {
                    edge: root.edge
                }
            }
            DelegateChoice {
                roleValue: BarEntry.gpu

                delegate: GpuPill {
                    edge: root.edge
                }
            }
            DelegateChoice {
                roleValue: BarEntry.memory

                delegate: MemoryPill {
                    edge: root.edge
                }
            }
        }
    }
}
