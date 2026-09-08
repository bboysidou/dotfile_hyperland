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
import qs.modules.controlcenter.panels
import qs.modules.dashboard.prayers
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
        Appearance.notif.historyMaxEntries,
        Appearance.notif.historySaveDebounce,
        ControlSection.values,
        AudioSection.values,
        NotifSection.values,
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
        NotifHistory.criticals,
        NotifHistory.bucket([]),
        ControlState.opened,
        PowerAction.values,
        PowerState.actions,
        PowerState.screen,
        PowerState.defaultIndex,
        PowerState.indexForKey(Appearance.power.shutdownKey),
        NotifSound.enabled,
        NotifSound.statePath,
        Prayers.methods,
        Prayers.asrSchools,
        Prayers.highLatRules,
        Prayers.fallbackPlace,
        Prayers.defaultIshaAngle,
        PrayerName.values,
        PrayerName.alerting,
        PrayerName.labels,
        Appearance.prayer.alertOffsets,
        Appearance.prayer.notifyIdBase,
        Appearance.prayer.zoneWarning,
        Appearance.dash.labelPrayers,
        Icons.prayersTab,
        Icons.place,
        Icons.pinOff,
        Icons.sunriseMarker,
        Solar.julianDay(2026, 9, 8),
        Solar.riseSetAngle(0),
        Geo.detecting,
        Geo.error,
        Geo.results,
        Geo.searching,
        Geo.offsetFor("Africa/Algiers"),
        Prayer.place,
        Prayer.source,
        Prayer.zoneMismatch,
        Prayer.today,
        Prayer.schedule,
        Prayer.current,
        Prayer.next,
        Prayer.countdown,
        Prayer.progress,
        Prayer.urgent,
        Prayer.methodConfig,
        Prayer.asrFactor,
        PrayerAlerts.fired,
        PrayerAlerts.queue,
        PrayerAlerts.sameMinute(new Date(), new Date()),
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
        Appearance.orbit.panelWidth,
        Appearance.orbit.maxNodes,
        Appearance.orbit.labelMore,
        Appearance.anim.durations.orbitMorph,
        Appearance.updates.repoMaxRatio,
        Appearance.updates.versionArrow,
        Icons.updateAur,
        Icons.refresh,
        Appearance.bar.workspacePillActiveWidth,
        Appearance.slider.roundingRatio,
        Appearance.bar.workspaceExtendDuration,
        Appearance.bar.workspaceHoverScale,
        Appearance.bar.workspacePressScale,
        Appearance.bar.workspaceStaggerStep,
        Appearance.bar.workspaceWheelThreshold,
        Appearance.bar.workspaceWheelReset
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
            InfoCard {}
            OrbitOrbs {}
            OrbitCore {}
            OrbitStrands {}
            OrbitNode {}
            OrbitStage {}
            Workspaces {}
            NetworkPill {}
            VolumeOrb {}
            SegmentBar {
                options: []
            }
            NotifPill {}
            NotifHero {
                count: 0
                label: ""
                title: ""
                detail: ""
                glyph: ""
                action: ""
            }
            NotifCard {
                group: ({
                        appName: "",
                        desktopEntry: "",
                        image: "",
                        latest: 0,
                        entries: []
                    })
            }
            PanelHeader {}
            PanelBody {}
            AudioPanel {}
            NetworkPanel {}
            BluetoothPanel {}
            NotifPanel {}
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
            PrayerPane {}
            PrayerNextCard {}
            PrayerListCard {}
            PrayerPlaceCard {}
            PrayerSettingsCard {}
            PrayerPill {}
            PrayerRow {
                entry: Prayer.today[0]
                active: false
                elapsed: false
                marker: false
            }
            PrayerSearchRow {
                place: Prayers.fallbackPlace
            }
            ShotList {}
            ShotEntry {
                entry: ShotState.actions[0]
                selected: false
            }
        }
    }
}
