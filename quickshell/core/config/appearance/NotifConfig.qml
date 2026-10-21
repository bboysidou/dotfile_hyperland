import QtQuick

QtObject {
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
    readonly property int timerThickness: 3
    readonly property int timerMargin: 8
    readonly property int ageThreshold: 60
    readonly property int slideDistance: 32
    readonly property int actionSpacing: 8
    readonly property int actionPaddingV: 4
    readonly property int actionPaddingH: 10
    readonly property int previewHeight: 140
    readonly property int previewRounding: 6
    readonly property int previewSourceWidth: 1000
    readonly property string previewCategory: "screenshot"
    readonly property int faviconTimeout: 5
    readonly property string faviconEndpoint: "https://icons.duckduckgo.com/ip2"
    readonly property string faviconCacheDir: "quickshell/favicons"
    readonly property var faviconBrowsers: ["firefox", "brave", "chromium", "google-chrome"]

    readonly property string soundFile: "/usr/share/sounds/freedesktop/stereo/message.oga"
    readonly property string soundStateFile: "sound.json"
    readonly property int soundSaveDebounce: 500
    readonly property string labelSound: "Notification sound"

    readonly property string historyFile: "notifications.json"
    readonly property string transientImagePrefix: "image://qsimage/"
    readonly property int historyVersion: 1
    readonly property int historyMaxEntries: 200
    readonly property int historyMaxAgeDays: 7
    readonly property int historySaveDebounce: 1000
    readonly property int historySweepInterval: 3600000
    readonly property int rowSpacing: 4
    readonly property int rowPaddingV: 6
    readonly property int rowPaddingH: 10
    readonly property int rowRounding: 10
    readonly property int bodyMaxLines: 2
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
