import QtQuick
import Quickshell
import qs.core.components
import qs.core.config
import qs.core.constants
import qs.core.enums
import qs.core.helpers
import qs.modules.bar.components
import qs.modules.controlcenter
import qs.modules.controlcenter.components
import qs.modules.controlcenter.notifications
import qs.modules.controlcenter.panes
import qs.modules.lock.components
import qs.modules.notifications.components
import qs.modules.power
import qs.modules.power.components
import qs.modules.screenshot
import qs.modules.screenshot.components
import qs.modules.updates
import qs.modules.updates.components
import qs.services

ShellRoot {
    readonly property var probes: [
        Appearance.tab.height,
        Appearance.control.topPaneMaxRatio,
        Appearance.notif.historyMaxEntries,
        Appearance.notif.historySaveDebounce,
        ControlSection.values,
        BarEntry.network,
        BarEntry.notifications,
        Units.minutesPerHour,
        Units.hoursPerDay,
        Fmt.relativeTime(Date.now()),
        Nav.vertical({
            key: Qt.Key_Down,
            modifiers: Qt.NoModifier
        }),
        Nav.horizontal({
            key: Qt.Key_H,
            modifiers: Qt.ControlModifier
        }),
        Net.glyph,
        Lock.unlocking,
        Lock.recovering,
        Appearance.lock.fadeInType,
        Appearance.lock.fadeOutType,
        Appearance.lock.dotCollapseScale,
        NotifHistory.unread,
        NotifHistory.groups,
        ControlState.opened,
        PowerAction.values,
        PowerState.actions,
        PowerState.screen,
        PowerState.defaultIndex,
        PowerState.indexForKey(Appearance.power.shutdownKey),
        ShotAction.values,
        ShotState.actions,
        ShotState.dir,
        ShotState.results,
        Appearance.shot.captureDelay,
        Appearance.shot.fileFormat,
        Appearance.shot.placeholder,
        Icons.shotRegion,
        Appearance.power.fadeInType,
        Appearance.power.selectedScale,
        Fmt.uptime(Units.secondsPerDay),
        Uptime.text,
        UpdatesState.opened,
        Updates.repo,
        Updates.aur,
        Updates.refreshing,
        Updates.parse(""),
        Appearance.updates.repoMaxRatio,
        Appearance.updates.versionArrow,
        Icons.updateAur,
        Icons.refresh
    ]

    readonly property Component components: Component {
        Item {
            TabStrip {
                tabs: []
            }
            EmptyState {
                glyph: ""
                title: ""
                subtitle: ""
            }
            NetworkPill {}
            NotifPill {}
            AudioPane {}
            NetworkPane {}
            BluetoothPane {}
            PaneHeader {}
            NotifList {}
            ControlPanel {}
            UpdatesCenter {}
            UpdatesPanel {}
            UpdatesHeader {}
            UpdateSection {
                glyph: ""
                title: ""
                placeholder: ""
                entries: []
            }
            UpdateRow {
                entry: ({
                        name: "",
                        from: "",
                        to: ""
                    })
            }
            Password {}
            Identity {}
            Connectivity {}
            MediaChip {}
            Batteries {}
            PowerHeader {}
            PowerTile {
                icon: ""
                label: ""
                selected: false
            }
            ShotList {}
            ShotEntry {
                entry: ShotState.actions[0]
                selected: false
            }
        }
    }
}
