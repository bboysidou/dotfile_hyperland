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
    readonly property string avatarCacheDir: "quickshell/notif-avatars"
    readonly property int avatarGrabScale: 2
    readonly property string fileScheme: "file://"
    readonly property var faviconBrowsers: ["zen", "firefox", "librewolf", "floorp", "brave", "chromium", "google-chrome"]
    readonly property var originBrowsers: ["zen", "firefox", "librewolf", "floorp"]
    readonly property string originScript: "system/qs-notif-origin"
    readonly property int badgeSize: 16
    readonly property string originTemplate: "%1  ·  %2"

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

    readonly property int recentLimit: 10
    readonly property int progressMax: 100
    readonly property int progressThickness: 6
    readonly property int toolSize: 14
    readonly property int copiedTimeout: 1500
    readonly property string labelReply: "Reply"
    readonly property string labelSend: "Send"
    readonly property string replyPlaceholder: "Reply…"
    readonly property string codeTemplate: "Copy %1"
    readonly property string copiedLabel: "Copied"
    readonly property string progressTemplate: "%1%"
    readonly property string restoredFlag: "string:x-qs-restored:1"
    readonly property string focusLua: 'hl.dsp.focus({ window = "address:0x%1" })'
    readonly property string focusLegacy: "focuswindow address:0x%1"
}
