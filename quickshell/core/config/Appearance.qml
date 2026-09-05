pragma Singleton

import QtQuick
import Quickshell
import qs.core.enums

Singleton {
    id: root

    component FontFamily: QtObject {
        readonly property string sans: "JetBrainsMono Nerd Font"
        readonly property string mono: "JetBrainsMono Nerd Font"
        readonly property string icons: "JetBrainsMono Nerd Font"
    }

    component FontSize: QtObject {
        readonly property int tiny: 10
        readonly property int small: 11
        readonly property int normal: 14
        readonly property int large: 16
    }

    component FontConfig: QtObject {
        readonly property FontFamily family: FontFamily {}
        readonly property FontSize size: FontSize {}
        readonly property int weightNormal: Font.Bold
        readonly property int weightActive: Font.ExtraBold
        readonly property int weightIcon: Font.Normal
    }

    component PaddingConfig: QtObject {
        readonly property int none: 0
        readonly property int tiny: 1
        readonly property int small: 2
        readonly property int normal: 8
        readonly property int large: 15
    }

    component SpacingConfig: QtObject {
        readonly property int none: 0
        readonly property int small: 7
        readonly property int normal: 10
        readonly property int large: 12
        readonly property int huge: 45
    }

    component RoundingConfig: QtObject {
        readonly property int tiny: 2
        readonly property int small: 5
        readonly property int normal: 8
        readonly property int large: 16
        readonly property int full: 1000
    }

    component CurveConfig: QtObject {
        readonly property var standard: [0.2, 0, 0, 1, 1, 1]
        readonly property var standardAccel: [0.3, 0, 1, 1, 1, 1]
        readonly property var standardDecel: [0, 0, 0, 1, 1, 1]
        readonly property var emphasized: [0.05, 0, 0.133333, 0.06, 0.166667, 0.4, 0.208333, 0.82, 0.25, 1, 1, 1]
        readonly property var emphasizedAccel: [0.3, 0, 0.8, 0.15, 1, 1]
        readonly property var emphasizedDecel: [0.05, 0.7, 0.1, 1, 1, 1]
        readonly property var fastSpatial: [0.42, 1.67, 0.21, 0.9, 1, 1]
        readonly property var defaultSpatial: [0.38, 1.21, 0.22, 1, 1, 1]
        readonly property var slowSpatial: [0.39, 1.29, 0.35, 0.98, 1, 1]
        readonly property var fastEffects: [0.31, 0.94, 0.34, 1, 1, 1]
        readonly property var defaultEffects: [0.34, 0.8, 0.34, 1, 1, 1]
        readonly property var slowEffects: [0.34, 0.88, 0.34, 1, 1, 1]
    }

    component DurationConfig: QtObject {
        readonly property int small: 200
        readonly property int normal: 400
        readonly property int large: 600
        readonly property int extraLarge: 1000
        readonly property int fastSpatial: 350
        readonly property int defaultSpatial: 500
        readonly property int slowSpatial: 650
        readonly property int fastEffects: 150
        readonly property int defaultEffects: 200
        readonly property int slowEffects: 300
    }

    component AnimConfig: QtObject {
        readonly property CurveConfig curves: CurveConfig {}
        readonly property DurationConfig durations: DurationConfig {}
    }

    component BorderConfig: QtObject {
        readonly property int thickness: 8
        readonly property int rounding: 20
        readonly property int fillet: 36
    }

    component ElevationConfig: QtObject {
        readonly property var levels: [0, 1, 3, 6, 8, 12]
        readonly property real opacity: 0.7
        readonly property real blurScale: 5
        readonly property real blurExponent: 0.7
        readonly property real spreadScale: 0.3
        readonly property real spreadCurve: 0.1
        readonly property int panel: 3
    }

    component StateLayerConfig: QtObject {
        readonly property real hoverOpacity: 0.08
        readonly property real pressOpacity: 0.12
    }

    component FadeConfig: QtObject {
        readonly property real amount: 0.12
        readonly property int flickVelocity: 3000
    }

    component DotConfig: QtObject {
        readonly property int size: 12
        readonly property int spacing: 10
        readonly property real scaleFrom: 0.3
    }

    component StateConfig: QtObject {
        readonly property string dir: "quickshell"
    }

    component ScaleConfig: QtObject {
        readonly property int fraction: 1
        readonly property int percent: 100
        readonly property string percentTemplate: "%1%"
    }

    component AudioConfig: QtObject {
        readonly property int max: 100
        readonly property int step: 1
        readonly property int mediumFloor: 31
        readonly property int highFloor: 66
    }

    component MarqueeConfig: QtObject {
        readonly property int interval: 300
        readonly property int fallbackLength: 20
        readonly property int minLength: 10
        readonly property int maxLength: 20
        readonly property string separator: "   "
    }

    component BarConfig: QtObject {
        readonly property int height: 34
        readonly property int paddingSide: 0
        readonly property int pillPaddingV: 2
        readonly property int pillPaddingH: 8
        readonly property int pillMarginRight: 10
        readonly property int workspacePadding: 1
        readonly property int workspaceMarginV: 4
        readonly property int workspaceMarginLeft: 7
        readonly property int workspaceFontSize: 15
        readonly property int workspaceDotSize: 16
        readonly property int workspacesMinimum: 3
        readonly property real workspaceHoverOpacity: 0.5
        readonly property int archMarginLeft: 5
        readonly property int archMarginRight: 7
        readonly property int sliderTroughHeight: 8
        readonly property int sliderTroughWidth: 75
        readonly property int ringSize: 16
        readonly property real ringRadiusRatio: 0.4
        readonly property real ringThicknessRatio: 0.16
        readonly property int ringMarginLeft: 2
        readonly property int usageWarning: 70
        readonly property int usageCritical: 90
        readonly property int usagePollInterval: 10000
        readonly property int usagePrimeDelay: 300
        readonly property int mousePollInterval: 300000
        readonly property int mouseWarning: 30
        readonly property int mouseCritical: 15
        readonly property int mediaMarginLeft: 12
        readonly property int mediaMarginRight: 10
        readonly property int mediaFrameInterval: 100
        readonly property int mediaGapMin: 20
        readonly property int mediaPositionInterval: 1000
        readonly property int volumeMarginLeft: 8
        readonly property int sliderFillMinWidth: 10
        readonly property int sliderRounding: 5
        readonly property int updatesMarginLeft: 45
        readonly property int updatesMarginRight: 12
        readonly property int trayIconSize: 16
        readonly property int traySpacing: 8
        readonly property real trayPassiveOpacity: 0.5
        readonly property int trayHitSize: 24
        readonly property int trayHitRounding: 8
        readonly property int trayTooltipGap: 14
        readonly property int trayTooltipPaddingH: 10
        readonly property int trayTooltipPaddingV: 6
        readonly property int trayTooltipRounding: 10
        readonly property string trayUnknownLabel: "Unknown"
        readonly property string clockFormat: "ddd, dd. MMM HH:mm"
        readonly property var entriesLeft: [BarEntry.osIcon, BarEntry.workspaces, BarEntry.updates, BarEntry.media]
        readonly property var entriesCentre: [BarEntry.worldClock]
        readonly property var entriesRight: [BarEntry.tray, BarEntry.cpu, BarEntry.memory, BarEntry.mouseBattery, BarEntry.network, BarEntry.bluetooth, BarEntry.notifications, BarEntry.volume]
    }

    component GaugeConfig: QtObject {
        readonly property int size: 152

        readonly property real strokeRatio: 0.066
        readonly property real spacingRatio: 0.04
        readonly property real valueRatio: 0.138
        readonly property real labelRatio: 0.079
        readonly property real secondaryRatio: 0.079
        readonly property real centreSpacingRatio: 0.013
        readonly property real allowanceRatio: 0.13
        readonly property real iconRatio: 0.26

        readonly property real lowerStart: 45
        readonly property real upperStart: 225
        readonly property real halfSpan: 180
        readonly property real textGap: 58
        readonly property real textRadiusRatio: 1
        readonly property real trackOpacity: 0.28
        readonly property real secondaryShade: 0.68
    }

    component TabConfig: QtObject {
        readonly property int height: 34
        readonly property int spacing: 4
        readonly property int paddingH: 16
        readonly property int iconSpacing: 8
        readonly property int rounding: 12
        readonly property int iconSize: 15
        readonly property int indicatorHeight: 3
        readonly property int indicatorRounding: 2
    }

    component DashConfig: QtObject {
        readonly property int padding: 16
        readonly property int spacing: 12
        readonly property real scaleFrom: 0.97
        readonly property int hoverCloseDelay: 220
        readonly property int detailPollInterval: 2000

        readonly property int iconButtonSize: 20

        readonly property int cardRounding: 16
        readonly property int cardPadding: 14
        readonly property int cardSpacing: 8
        readonly property int cardLabelSize: 11
        readonly property real cardLabelOpacity: 0.7

        readonly property int userAvatarSize: 62
        readonly property int userAvatarIconSize: 34
        readonly property int userNameSize: 19
        readonly property int userSpacing: 14

        readonly property int clockWidth: 214
        readonly property int clockRowHeight: 24
        readonly property int clockRefreshInterval: 1800000
        readonly property string clockTimeFormat: "HH:mm"
        readonly property string clockPlaceholder: "--:--"
        readonly property string clockNextDay: "+1"
        readonly property string clockPrevDay: "-1"
        readonly property var clockZones: [
            {
                label: "Montreal",
                zone: "America/Montreal"
            },
            {
                label: "Alberta",
                zone: "America/Edmonton"
            },
            {
                label: "San Francisco",
                zone: "America/Los_Angeles"
            }
        ]

        readonly property int dateTimeSize: 38
        readonly property string dateTimeFormat: "HH:mm"
        readonly property string dateDayFormat: "dddd"
        readonly property string dateRestFormat: "dd MMM yyyy"

        readonly property int calendarWidth: 268
        readonly property int calendarCellSize: 32
        readonly property int calendarCellRounding: 10
        readonly property int calendarColumns: 7
        readonly property int calendarRows: 6
        readonly property int calendarHeaderHeight: 26
        readonly property real calendarOtherMonthOpacity: 0.3
        readonly property string calendarMonthFormat: "MMMM yyyy"
        readonly property int calendarNavSize: 16
        readonly property int calendarNavButtonSize: 24
        readonly property int calendarNavSpacing: 2
        readonly property int calendarMonthRange: 1200
        readonly property var calendarDayLabels: ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]

        readonly property int resourceGaugeSize: 84
        readonly property int resourceRingSize: 58
        readonly property int resourceSpacing: 12
        readonly property real resourceRadiusRatio: 0.42
        readonly property real resourceThicknessRatio: 0.1

        readonly property int mediaCardWidth: 218
        readonly property int mediaArtRounding: 12
        readonly property int mediaControlSize: 19
        readonly property int mediaControlSpacing: 18
        readonly property int mediaTitleBudget: 190
        readonly property int mediaTitleMax: 24

        readonly property int notifCount: 3

        readonly property int gaugeSpacing: 0
        readonly property int gaugeSizeMain: 162
        readonly property int gaugeSizeSide: 126
        readonly property int cpuTempMax: 100
        readonly property real gaugeStart: -90
        readonly property real gaugeSpan: 360

        readonly property int visualiserBars: 44
        readonly property int visualiserFramerate: 30
        readonly property int visualiserLowFreq: 50
        readonly property int visualiserHighFreq: 10000
        readonly property int visualiserRange: 100
        readonly property real visualiserNoiseReduction: 0.85
        readonly property real visualiserFalloff: 1.5
        readonly property int vinylSize: 168
        readonly property int vinylSizeSmall: 96
        readonly property int visualiserMagnitudeSmall: 20
        readonly property int vinylLabelSizeSmall: 26
        readonly property int vinylSpinDuration: 12000
        readonly property int vinylLabelSize: 44
        readonly property int visualiserGap: 9
        readonly property int visualiserMagnitude: 30
        readonly property int visualiserMinBar: 3
        readonly property real visualiserBarWidthRatio: 0.55

        readonly property int transportSize: 20
        readonly property int transportPrimarySize: 26
        readonly property int transportSpacing: 18
        readonly property int sourceChipHeight: 28
        readonly property int sourceChipPaddingH: 12
        readonly property int sourceChipRounding: 14

        readonly property int netRateWidth: 78
        readonly property int perfCardMinWidth: 210
        readonly property int perfHeroRingSize: 104
        readonly property int perfHeroValueSize: 24
        readonly property int perfBarHeight: 8
        readonly property int perfRowSpacing: 7
        readonly property int perfValueSize: 17
        readonly property int tempWarning: 70
        readonly property int tempCritical: 85
        readonly property string tempTemplate: "%1\u00b0C"
        readonly property int storageMax: 4
        readonly property int netHistory: 46
        readonly property int netSparkHeight: 42
        readonly property real netScaleFloor: 262144
        readonly property real sparkFillOpacity: 0.18

        readonly property int mediaTabWidth: 748
        readonly property int mediaTabHeight: 296
        readonly property int mediaCoverSize: 252
        readonly property int mediaCoverRounding: 18
        readonly property real backdropBlur: 1
        readonly property real backdropOpacity: 0.4
        readonly property real backdropScale: 1.6
        readonly property int seekHeight: 6
        readonly property int seekSpacing: 6
        readonly property int detailTitleSize: 23
        readonly property int detailArtistSize: 15
        readonly property int detailAlbumSize: 12
        readonly property int detailTitleMax: 44
        readonly property int detailTitleBudget: 420
        readonly property int detailControlSize: 26
        readonly property int detailControlSpacing: 22
        readonly property int selectorHeight: 30
        readonly property int selectorSpacing: 6
        readonly property int selectorPaddingH: 12
        readonly property int selectorRounding: 10
        readonly property int selectorMax: 4
        readonly property string emptyTitle: "Nothing playing"
        readonly property string emptySubtitle: "Start something and it will show up here"
        readonly property int emptyIconSize: 46
        readonly property int emptySpacing: 6

        readonly property string labelWorldClock: "World clock"
        readonly property string labelCpu: "CPU"
        readonly property string labelMemory: "Memory"
        readonly property string labelSwap: "Swap"
        readonly property string labelStorage: "Storage"
        readonly property string labelHardware: "Hardware"
        readonly property string labelCpuTemp: "CPU temp"
        readonly property string labelUsage: "Usage"
        readonly property string labelTotal: "Total"
        readonly property string labelUsed: "Used"
        readonly property string labelNetwork: "Network"
        readonly property string labelDash: "Dashboard"
        readonly property string labelPerformance: "Performance"
        readonly property string labelMedia: "Media"
        readonly property string labelNotifications: "Notifications"
        readonly property string labelNoNotifications: "Nothing new"
        readonly property string labelNoStorage: "No filesystems"
        readonly property string labelNoTemp: "--"
    }

    component NotifConfig: QtObject {
        readonly property int stackPadding: 6
        readonly property int stackSpacing: 6
        readonly property int widthMin: 300
        readonly property int widthMax: 500
        readonly property int heightMin: 70
        readonly property int heightMax: 300
        readonly property int rounding: 10
        readonly property int maxVisible: 3
        readonly property int paddingV: 10
        readonly property int paddingH: 12
        readonly property int iconSpacing: 8
        readonly property int iconSize: 32
        readonly property int timeoutLow: 3000
        readonly property int timeoutNormal: 3000
        readonly property int timeoutCritical: 0
        readonly property int ageThreshold: 60
        readonly property int slideDistance: 32
        readonly property int actionSpacing: 8
        readonly property int actionPaddingV: 4
        readonly property int actionPaddingH: 10
        readonly property int faviconTimeout: 5
        readonly property string faviconEndpoint: "https://icons.duckduckgo.com/ip2"
        readonly property string faviconCacheDir: "quickshell/favicons"
        readonly property var faviconBrowsers: ["firefox", "brave", "chromium", "google-chrome"]

        readonly property string historyFile: "notifications.json"
        readonly property int historyVersion: 1
        readonly property int historyMaxEntries: 200
        readonly property int historyMaxAgeDays: 7
        readonly property int historySaveDebounce: 1000
        readonly property int historySweepInterval: 3600000
        readonly property int cardRounding: 12
        readonly property int cardSpacing: 6
        readonly property int cardHeaderHeight: 34
        readonly property int cardPaddingH: 10
        readonly property int cardIconSize: 18
        readonly property int rowSpacing: 4
        readonly property int rowPaddingV: 6
        readonly property int rowPaddingH: 10
        readonly property int rowRounding: 10
        readonly property int bodyMaxLines: 2
        readonly property int listSpacing: 6
        readonly property int headerHeight: 28
        readonly property int badgePaddingH: 6
        readonly property int badgeRounding: 999
        readonly property int clearIconSize: 14
        readonly property string relativeNow: "now"
        readonly property string labelNotifications: "Notifications"
        readonly property string labelClearAll: "Clear all"
        readonly property string labelUnknownApp: "Notification"
        readonly property string emptyTitle: "All caught up"
        readonly property string emptySubtitle: "Nothing waiting for you"
    }

    component SearchConfig: QtObject {
        readonly property int paddingV: 12
        readonly property int paddingH: 16
        readonly property int spacing: 10
        readonly property int iconSize: 16
    }

    component LauncherConfig: QtObject {
        readonly property int width: 500
        readonly property int padding: 20
        readonly property int spacing: 10
        readonly property int visibleRows: 8
        readonly property int rowSpacing: 5
        readonly property int rowPaddingV: 6
        readonly property int rowPaddingH: 10
        readonly property int rowContentSpacing: 10
        readonly property int rowRounding: 12
        readonly property int iconSize: 32
        readonly property real scaleFrom: 0.95
        readonly property real subtitleOpacity: 0.7
        readonly property string placeholder: "Search..."
        readonly property string actionPrefix: ">"
        readonly property string wallpaperAction: "wallpaper"
        readonly property string wallpaperPlaceholder: "Wallpaper..."
        readonly property int wallpaperItemWidth: 200
        readonly property int wallpaperItemPadding: 10
        readonly property int wallpaperItemRounding: 12
        readonly property int wallpaperLabelSpacing: 6
        readonly property int wallpaperLabelHeight: 18
        readonly property int wallpaperMax: 5
        readonly property int wallpaperElevation: 4
        readonly property real wallpaperSideScale: 0.8
        readonly property real wallpaperAspect: 0.5625
        readonly property string usageCacheDir: "quickshell/launcher"
        readonly property string usageCacheFile: "usage.json"
        readonly property int scoreExact: 100
        readonly property int scorePrefix: 90
        readonly property int scoreWordPrefix: 80
        readonly property int scoreSubstring: 70
        readonly property int scoreMeta: 60
        readonly property int scoreComment: 50
        readonly property int scoreSubsequence: 40
    }

    component ControlConfig: QtObject {
        readonly property int width: 380
        readonly property int padding: 14
        readonly property real scaleFrom: 0.96
        readonly property real topPaneMaxRatio: 0.5
        readonly property int tabStripMargin: 10
        readonly property int paneSpacing: 8
        readonly property int sectionSpacing: 6
        readonly property int sectionHeaderHeight: 34
        readonly property int sectionHeaderSpacing: 10
        readonly property int sectionIconSize: 18
        readonly property int sectionRounding: 12
        readonly property int sectionContentSpacing: 4
        readonly property int rowHeight: 34
        readonly property int rowPaddingV: 6
        readonly property int rowPaddingH: 10
        readonly property int rowSpacing: 10
        readonly property int rowRounding: 10
        readonly property int iconSize: 18
        readonly property int sliderWidth: 90
        readonly property int toggleWidth: 36
        readonly property int toggleHeight: 18
        readonly property int togglePadding: 2
        readonly property int focusBorderWidth: 1
        readonly property real disabledOpacity: 0.4
        readonly property int passwordPaddingV: 8
        readonly property int passwordPaddingH: 12
        readonly property int passwordSpacing: 8
        readonly property int forgetConfirmTimeout: 3000
        readonly property int wifiSignalLow: 25
        readonly property int wifiSignalMedium: 50
        readonly property int wifiSignalHigh: 75
        readonly property string passwordPlaceholder: "Password"
        readonly property string emptyNoWifiDevice: "No Wi-Fi adapter"
        readonly property string emptyWifiDisabled: "Wi-Fi is off"
        readonly property string emptyScanning: "Scanning..."
        readonly property string emptyNoBluetooth: "No Bluetooth adapter"
        readonly property string emptyBluetoothDisabled: "Bluetooth is off"
        readonly property string emptyNoDevices: "No devices"
        readonly property string labelOutput: "Output"
        readonly property string labelInput: "Input"
        readonly property string labelStreams: "Applications"
        readonly property string labelNetwork: "Network"
        readonly property string labelBluetooth: "Bluetooth"
        readonly property string labelAudio: "Audio"
        readonly property string labelConnecting: "Connecting..."
        readonly property string labelConnected: "Connected"
        readonly property string labelSaved: "Saved"
        readonly property string labelForgetConfirm: "Confirm"
        readonly property string failureNoSecrets: "Wrong password"
        readonly property string failureAuthTimeout: "Authentication timed out"
        readonly property string failureNetworkLost: "Network out of range"
        readonly property string failureDisconnected: "Disconnected"
        readonly property string failureGeneric: "Connection failed"
    }

    component UpdatesConfig: QtObject {
        readonly property int width: 380
        readonly property int padding: 14
        readonly property real scaleFrom: 0.96
        readonly property int pollInterval: 1800000
        readonly property int timeout: 120
        readonly property int headerHeight: 40
        readonly property int headerSpacing: 10
        readonly property int headerIconSize: 20
        readonly property int actionSize: 18
        readonly property int actionSpacing: 12
        readonly property int spinDuration: 900
        readonly property real repoMaxRatio: 0.5
        readonly property int sectionSpacing: 8
        readonly property int sectionRounding: 12
        readonly property int sectionPaddingV: 6
        readonly property int sectionHeaderHeight: 26
        readonly property int sectionHeaderSpacing: 8
        readonly property int sectionIconSize: 16
        readonly property int listSpacing: 2
        readonly property int rowHeight: 32
        readonly property int rowSpacing: 8
        readonly property int rowPaddingH: 10
        readonly property int rowRounding: 8
        readonly property int versionMaxWidth: 96
        readonly property string title: "Updates"
        readonly property string labelRepo: "Repository"
        readonly property string labelAur: "AUR"
        readonly property string versionArrow: "\u2192"
        readonly property string emptyTitle: "Up to date"
        readonly property string emptySubtitle: "No packages waiting"
        readonly property string emptyRepo: "No repository updates"
        readonly property string emptyAur: "No AUR updates"
    }

    component WallpaperConfig: QtObject {
        readonly property string dir: "Pictures/wallpaper"
        readonly property string stateFile: "wallpaper"
        readonly property var extensions: ["jpg", "jpeg", "png", "gif"]
        readonly property string hyprpaperConf: ".config/hypr/hyprpaper.conf"
        readonly property string seedPattern: "^\\s*path\\s*=\\s*(.+)$"
    }

    component LockConfig: QtObject {
        readonly property string clockFont: "Alfa Slab One"
        readonly property string labelFont: "SF Pro Display"
        readonly property int labelWeight: Font.Bold
        readonly property int clockWeight: Font.Normal
        readonly property int clockFontSize: 240
        readonly property int dateFontSize: 40
        readonly property int greetingFontSize: 21
        readonly property int identityFontSize: 15
        readonly property int clockSpacing: -60
        readonly property int centreSpacing: 12
        readonly property int fieldWidth: 250
        readonly property int fieldHeight: 60
        readonly property int fieldRounding: 1000
        readonly property int fieldBorderWidth: 2
        readonly property int fieldTopMargin: 40
        readonly property real blur: 1.0
        readonly property int blurMax: 64
        readonly property real backgroundDim: 0.35
        readonly property int logoSize: 100
        readonly property real logoOpacity: 0.25
        readonly property int edgeMargin: 20
        readonly property int identitySpacing: 12
        readonly property int statusSpacing: 10
        readonly property int statusPaddingV: 6
        readonly property int statusPaddingH: 12
        readonly property int statusRounding: 12
        readonly property int statusIconSize: 18
        readonly property int statusFontSize: 16
        readonly property int messageFontSize: 17
        readonly property int messageTopMargin: 12
        readonly property int mediaMaxWidth: 320
        readonly property int faillockDeny: 3
        readonly property string fadeInType: AnimType.standardLarge
        readonly property string fadeOutType: AnimType.standard
        readonly property int shakeAmplitude: 12
        readonly property int shakeStep: 55
        readonly property real shakeDecay: 0.5
        readonly property int flashHold: 500
        readonly property real dotCollapseScale: 0.85
        readonly property string pamConfig: "hyprlock"
        readonly property string stateFile: "lock_failures"
        readonly property string greetingTemplate: "Hello, %1! %2"
        readonly property string placeholderTemplate: "Hi, %1"
        readonly property string failureSingular: "%1 failed attempt"
        readonly property string failurePlural: "%1 failed attempts"
        readonly property string missedTemplate: "%1 missed"
        readonly property string greetingMorning: "Good Morning"
        readonly property string greetingAfternoon: "Good Afternoon"
        readonly property string greetingEvening: "Good Evening"
        readonly property string greetingNight: "Good Night"
        readonly property string greetingLate: "GO TO SLEEP!"
        readonly property int hourMorning: 5
        readonly property int hourAfternoon: 12
        readonly property int hourEvening: 17
        readonly property int hourNight: 21
        readonly property string dateFormat: "dddd, dd MMMM"
        readonly property string hourFormat: "HH"
        readonly property string minuteFormat: "mm"
        readonly property string packagesTemplate: "Packages: %1 pacman"
        readonly property string emptyNoNetwork: "Offline"
        readonly property string emptyNoBluetooth: "Bluetooth off"
    }

    component OsdConfig: QtObject {
        readonly property int columnWidth: 38
        readonly property int columnHeight: 250
        readonly property int padding: 8
        readonly property int cardRounding: 12
        readonly property real inactiveOpacity: 0.45
        readonly property int rounding: 16
        readonly property int paddingV: 14
        readonly property int spacing: 14
        readonly property int iconSize: 22
        readonly property int labelSize: 15
        readonly property int meterThickness: 16
        readonly property int meterRounding: 8
        readonly property int timeout: 1600
        readonly property int primeDelay: 800
        readonly property real scaleFrom: 0.96
    }

    component PolkitConfig: QtObject {
        readonly property int width: 420
        readonly property int rounding: 16
        readonly property int borderWidth: 2
        readonly property int padding: 20
        readonly property int spacing: 12
        readonly property int iconSize: 32
        readonly property int titleSize: 16
        readonly property int bodySize: 13
        readonly property int fieldHeight: 40
        readonly property int fieldRounding: 1000
        readonly property int dotSize: 10
        readonly property int dotSpacing: 8
        readonly property int actionSpacing: 10
        readonly property int actionPaddingV: 6
        readonly property int actionPaddingH: 14
        readonly property int actionRounding: 10
        readonly property real scaleFrom: 0.96
        readonly property string title: "Authentication required"
        readonly property string confirmLabel: "Authenticate"
        readonly property string cancelLabel: "Cancel"
    }

    component ShotConfig: QtObject {
        readonly property int width: 500
        readonly property int padding: 20
        readonly property int spacing: 10
        readonly property int rowSpacing: 5
        readonly property int rowPaddingV: 6
        readonly property int rowPaddingH: 10
        readonly property int rowContentSpacing: 10
        readonly property int rowRounding: 12
        readonly property int iconSize: 32
        readonly property real scaleFrom: 0.95
        readonly property real subtitleOpacity: 0.7
        readonly property string placeholder: "Screenshot..."
        readonly property int captureDelay: 450
        readonly property int fullscreenDelay: 1
        readonly property string dir: "Pictures/screenshots"
        readonly property string fileFormat: "'screenshot_'ddMMyyyy_HHmmss'.png'"
        readonly property string regionLabel: "Selected area"
        readonly property string fullscreenLabel: "Fullscreen"
        readonly property string ocrLabel: "OCR"
        readonly property string regionSubtitle: "Drag to pick a region"
        readonly property string fullscreenSubtitle: "Whole screen after 1s"
        readonly property string ocrSubtitle: "Region to text, copied to clipboard"
    }

    component PowerConfig: QtObject {
        readonly property int tileSize: 132
        readonly property int tileRounding: 28
        readonly property int tileSpacing: 24
        readonly property int tileIconSize: 52
        readonly property int tileBorderWidth: 2
        readonly property int labelSize: 15
        readonly property int labelSpacing: 14
        readonly property real selectedScale: 1.08
        readonly property int sectionSpacing: 48
        readonly property int headerSpacing: 6
        readonly property int clockSize: 64
        readonly property int uptimeSize: 16
        readonly property int hintSize: 13
        readonly property real hintOpacity: 0.9
        readonly property real blur: 1.0
        readonly property int blurMax: 64
        readonly property real backgroundDim: 0.55
        readonly property string fadeInType: AnimType.standardLarge
        readonly property string fadeOutType: AnimType.standard
        readonly property string clockFormat: "HH:mm"
        readonly property string uptimeTemplate: "up %1"
        readonly property string uptimeUnknown: "?"
        readonly property string hint: "esc cancel \u00b7 \u21b5 select"
        readonly property string lockLabel: "Lock"
        readonly property string logoutLabel: "Logout"
        readonly property string rebootLabel: "Reboot"
        readonly property string shutdownLabel: "Shutdown"
        readonly property string lockKey: "l"
        readonly property string logoutKey: "o"
        readonly property string rebootKey: "r"
        readonly property string shutdownKey: "s"
    }

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
    readonly property MarqueeConfig marquee: MarqueeConfig {}
    readonly property BarConfig bar: BarConfig {}
    readonly property GaugeConfig gauge: GaugeConfig {}
    readonly property TabConfig tab: TabConfig {}
    readonly property DashConfig dash: DashConfig {}
    readonly property NotifConfig notif: NotifConfig {}
    readonly property SearchConfig search: SearchConfig {}
    readonly property LauncherConfig launcher: LauncherConfig {}
    readonly property ControlConfig control: ControlConfig {}
    readonly property UpdatesConfig updates: UpdatesConfig {}
    readonly property WallpaperConfig wallpaper: WallpaperConfig {}
    readonly property LockConfig lock: LockConfig {}
    readonly property OsdConfig osd: OsdConfig {}
    readonly property PolkitConfig polkit: PolkitConfig {}
    readonly property PowerConfig power: PowerConfig {}
    readonly property ShotConfig shot: ShotConfig {}
}
