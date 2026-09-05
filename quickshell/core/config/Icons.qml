pragma Singleton

import Quickshell

Singleton {
    id: root

    readonly property string arch: "\uDB82\uDCC7"
    readonly property string workspaceActive: "\uF192"
    readonly property string workspaceDefault: "\uF111"
    readonly property string updates: "\uDB81\uDEB0"
    readonly property string cpu: "\uDB80\uDF5B"
    readonly property string memory: "\uF2DB"
    readonly property string mouse: "\uDB80\uDF7D"
    readonly property string mouseCharging: "\uDB82\uDC15"
    readonly property string mediaPaused: "\uF04C"
    readonly property string volumeOff: "\uDB81\uDF5F"
    readonly property string volumeLow: "\uDB81\uDD7F"
    readonly property string volumeMedium: "\uDB81\uDD80"
    readonly property string volumeHigh: "\uDB81\uDD7E"
    readonly property string volumeMuted: "\uDB81\uDD81"
    readonly property string clock: "\uDB82\uDD54"
    readonly property string brightness: "\uDB80\uDCDF"
    readonly property string shield: "\uDB80\uDD98"
    readonly property string bluetooth: "\uDB80\uDCAF"
    readonly property string bluetoothDisabled: "\uDB80\uDCB2"
    readonly property string notifNormal: "\udb84\udd6b"
    readonly property string notifCritical: "\udb81\udebd"
    readonly property string launcherSearch: "\uDB80\uDF49"
    readonly property string launcherApp: "\uDB82\uDCC6"
    readonly property string wallpaper: "\uDB80\uDEE9"
    readonly property string shotRegion: "\uDB80\uDD9E"
    readonly property string shotFullscreen: "\uDB83\uDE51"
    readonly property string shotOcr: "\uDB84\uDD3A"
    readonly property string wifiOff: "\uDB81\uDDAA"
    readonly property string wifiDisabled: "\uDB82\uDD2D"
    readonly property string ethernet: "\uDB80\uDE00"
    readonly property string ethernetOff: "\uDB80\uDE02"
    readonly property string networkLocked: "\uDB80\uDF3E"
    readonly property string bluetoothConnected: "\uDB80\uDCB1"
    readonly property string microphone: "\uDB80\uDF6C"
    readonly property string microphoneMuted: "\uDB80\uDF6D"
    readonly property string close: "\uDB80\uDD56"
    readonly property string speaker: "\uDB81\uDCC3"
    readonly property string keyboard: "\uDB80\uDF0C"
    readonly property string headphones: "\uDB80\uDECB"
    readonly property string cellphone: "\uDB80\uDD1C"
    readonly property string gamepad: "\uDB80\uDE97"
    readonly property string watch: "\uDB81\uDD89"
    readonly property string printer: "\uDB81\uDC2A"
    readonly property string unknownDevice: "\uDB80\uDED7"
    readonly property string sectionExpanded: "\uDB80\uDD40"
    readonly property string sectionCollapsed: "\uDB80\uDD42"
    readonly property string forget: "\uDB80\uDDB4"
    readonly property string failure: "\uDB80\uDC28"
    readonly property string power: "\uDB81\uDC25"
    readonly property string restart: "\uDB81\uDF09"
    readonly property string lockScreen: "\uDB80\uDF3E"
    readonly property string logout: "\uDB80\uDF43"

    readonly property string dashTab: "\uDB81\uDD6E"
    readonly property string perfTab: "\uDB81\uDCC5"
    readonly property string mediaTab: "\uDB83\uDCB8"
    readonly property string person: "\uDB80\uDC04"
    readonly property string calendarMonth: "\uDB83\uDE17"
    readonly property string chevronLeft: "\uDB80\uDD41"
    readonly property string chevronRight: "\uDB80\uDD42"
    readonly property string thermometer: "\uDB81\uDD0F"
    readonly property string harddisk: "\uDB80\uDECA"
    readonly property string download: "\uDB80\uDDDA"
    readonly property string upload: "\uDB81\uDD52"
    readonly property string play: "\uDB81\uDC0A"
    readonly property string pause: "\uDB80\uDFE4"
    readonly property string skipNext: "\uDB81\uDCAD"
    readonly property string skipPrevious: "\uDB81\uDCAE"
    readonly property string swap: "\uDB81\uDCE6"
    readonly property string lan: "\uDB80\uDF18"
    readonly property string shuffle: "\uDB81\uDC9D"
    readonly property string repeatOff: "\uDB81\uDC57"
    readonly property string repeatAll: "\uDB81\uDC56"
    readonly property string repeatOnce: "\uDB81\uDC58"
    readonly property string musicNote: "\uDB80\uDF87"
    readonly property string album: "\uDB80\uDCA1"

    readonly property var mediaFrames: ["\u2582\u2584\u2586", "\u2584\u2582\u2586", "\u2584\u2586\u2582", "\u2586\u2584\u2582", "\u2586\u2582\u2584"]

    readonly property var mouseLevels: ["\uDB80\uDC8E", "\uDB80\uDC7A", "\uDB80\uDC7B", "\uDB80\uDC7C", "\uDB80\uDC7D", "\uDB80\uDC7E", "\uDB80\uDC7F", "\uDB80\uDC80", "\uDB80\uDC81", "\uDB80\uDC82", "\uDB80\uDC79"]
    readonly property var mouseCharge: ["\uDB82\uDC9F", "\uDB82\uDC9C", "\uDB80\uDC86", "\uDB80\uDC87", "\uDB80\uDC88", "\uDB82\uDC9D", "\uDB80\uDC89", "\uDB82\uDC9E", "\uDB80\uDC8A", "\uDB80\uDC8B", "\uDB80\uDC85"]
    readonly property var wifiLevels: ["\uDB82\uDD2F", "\uDB82\uDD1F", "\uDB82\uDD22", "\uDB82\uDD25", "\uDB82\uDD28"]
    readonly property var bluetoothDeviceGlyphs: ({
        "input-mouse": root.mouse,
        "input-keyboard": root.keyboard,
        "input-gaming": root.gamepad,
        "input-tablet": root.cellphone,
        "audio-headset": root.headphones,
        "audio-headphones": root.headphones,
        "audio-card": root.speaker,
        "audio-speakers": root.speaker,
        "phone": root.cellphone,
        "computer": root.unknownDevice,
        "printer": root.printer,
        "preferences-system-time": root.watch
    })
}
