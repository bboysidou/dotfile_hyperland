import QtQuick

QtObject {
    readonly property int width: 780
    readonly property int padding: 20
    readonly property int spacing: 14
    readonly property int headerSpacing: 12
    readonly property int iconSize: 32
    readonly property int titleSize: 16
    readonly property int bodySize: 13
    readonly property int columns: 3
    readonly property int maxRows: 2
    readonly property int cellSpacing: 10
    readonly property int tilePadding: 8
    readonly property int tileSpacing: 8
    readonly property int tileRounding: 12
    readonly property int tileBorderWidth: 2
    readonly property int previewHeight: 140
    readonly property int previewRounding: 8
    readonly property int previewIconSize: 40
    readonly property int labelIconSize: 16
    readonly property int labelSpacing: 6
    readonly property int emptyHeight: 160
    readonly property int actionSpacing: 10
    readonly property int actionContentSpacing: 6
    readonly property int actionPaddingV: 6
    readonly property int actionPaddingH: 14
    readonly property int actionRounding: 10
    readonly property int actionIconSize: 15
    readonly property real disabledOpacity: 0.4
    readonly property real scaleFrom: 0.96
    readonly property int replyTimeout: 2
    readonly property int regionTimeout: 15
    readonly property string title: "Share your screen"
    readonly property string subtitle: "An app wants to capture what you pick"
    readonly property string screensLabel: "Screens"
    readonly property string windowsLabel: "Windows"
    readonly property string regionLabel: "Region"
    readonly property string rememberLabel: "Remember choice"
    readonly property string cancelLabel: "Cancel"
    readonly property string shareLabel: "Share"
    readonly property string emptyTitle: "No windows"
    readonly property string emptySubtitle: "Open a window to share it"
    readonly property string resolutionTemplate: "%1 \u00D7 %2"
}
