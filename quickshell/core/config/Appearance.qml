pragma Singleton

import QtQuick
import Quickshell
import qs.core.config.appearance

Singleton {
    id: root

    readonly property FontConfig font: FontConfig {}
    readonly property PaddingConfig padding: PaddingConfig {}
    readonly property SpacingConfig spacing: SpacingConfig {}
    readonly property RoundingConfig rounding: RoundingConfig {}
    readonly property AnimConfig anim: AnimConfig {}
    readonly property BorderConfig border: BorderConfig {}
    readonly property ElevationConfig elevation: ElevationConfig {}
    readonly property StateLayerConfig stateLayer: StateLayerConfig {}
    readonly property FadeConfig fade: FadeConfig {}
    readonly property DotConfig dot: DotConfig {}
    readonly property StateConfig state: StateConfig {}
    readonly property ScaleConfig scale: ScaleConfig {}
    readonly property AudioConfig audio: AudioConfig {}
    readonly property SliderConfig slider: SliderConfig {}
    readonly property MarqueeConfig marquee: MarqueeConfig {}
    readonly property BarConfig bar: BarConfig {}
    readonly property GaugeConfig gauge: GaugeConfig {}
    readonly property TabConfig tab: TabConfig {}
    readonly property DashConfig dash: DashConfig {}
    readonly property PrayerConfig prayer: PrayerConfig {}
    readonly property NotifConfig notif: NotifConfig {}
    readonly property SearchConfig search: SearchConfig {}
    readonly property LauncherConfig launcher: LauncherConfig {}
    readonly property ControlConfig control: ControlConfig {}
    readonly property CardConfig card: CardConfig {}
    readonly property AudioPanelConfig audioPanel: AudioPanelConfig {}
    readonly property NotifPanelConfig notifPanel: NotifPanelConfig {}
    readonly property SegmentConfig segment: SegmentConfig {}
    readonly property UpdatesConfig updates: UpdatesConfig {}
    readonly property HardwareConfig hardware: HardwareConfig {}
    readonly property ThemeConfig theme: ThemeConfig {}
    readonly property WallpaperConfig wallpaper: WallpaperConfig {}
    readonly property LockConfig lock: LockConfig {}
    readonly property OsdConfig osd: OsdConfig {}
    readonly property PolkitConfig polkit: PolkitConfig {}
    readonly property PowerConfig power: PowerConfig {}
    readonly property PowerPanelConfig powerPanel: PowerPanelConfig {}
    readonly property LowPowerConfig lowPower: LowPowerConfig {}
    readonly property BatteryTabConfig batteryTab: BatteryTabConfig {}
    readonly property DisplayConfig display: DisplayConfig {}
    readonly property WeatherConfig weather: WeatherConfig {}
    readonly property EqualizerConfig equalizer: EqualizerConfig {}
    readonly property ShotConfig shot: ShotConfig {}
    readonly property ShareConfig share: ShareConfig {}
    readonly property OrbitConfig orbit: OrbitConfig {}
    readonly property KeybindsConfig keybinds: KeybindsConfig {}
    readonly property ClipboardConfig clipboard: ClipboardConfig {}
}
