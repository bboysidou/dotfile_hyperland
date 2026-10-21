import QtQuick
import qs.core.enums

QtObject {
    readonly property int height: 34
    readonly property int paddingSide: 0
    readonly property int pillPaddingV: 2
    readonly property int pillPaddingH: 8
    readonly property int pillMarginRight: 10
    readonly property int workspaceMarginLeft: 7
    readonly property int workspacesMinimum: 3
    readonly property int workspacePillActiveWidth: 30
    readonly property int workspacePillSpacing: 6
    readonly property int workspaceExtendDuration: 420
    readonly property real workspaceHoverScale: 1.15
    readonly property real workspacePressScale: 0.85
    readonly property int workspaceStaggerStep: 50
    readonly property int workspaceStaggerDelay: 100
    readonly property int workspaceWheelThreshold: 120
    readonly property int workspaceWheelReset: 200
    readonly property int archMarginLeft: 5
    readonly property int archMarginRight: 7
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
    readonly property var entriesCentre: [BarEntry.worldClock, BarEntry.prayers]
    readonly property var entriesRight: [BarEntry.tray, BarEntry.cpu, BarEntry.gpu, BarEntry.memory, BarEntry.mouseBattery, BarEntry.network, BarEntry.bluetooth, BarEntry.notifications, BarEntry.volume]
}
