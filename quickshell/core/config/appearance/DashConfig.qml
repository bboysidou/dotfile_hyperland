import QtQuick

QtObject {
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
    readonly property int vinylSpinDuration: 12000
    readonly property real vinylDiscRatio: 0.95
    readonly property real vinylLabelRatio: 0.35
    readonly property real vinylLabelX: 0.5095
    readonly property real vinylLabelY: 0.512
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

    readonly property int netRateWidth: 104
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
    readonly property string labelPrayers: "Prayers"
    readonly property string labelNotifications: "Notifications"
    readonly property string labelNoNotifications: "Nothing new"
    readonly property string labelNoStorage: "No filesystems"
    readonly property string labelNoTemp: "--"
}
