import QtQuick

QtObject {
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
    readonly property string themeAction: "theme"
    readonly property string themePlaceholder: "Theme..."
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
