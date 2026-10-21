import QtQuick

QtObject {
    readonly property int listWidth: 214
    readonly property int placeWidth: 268
    readonly property int rowHeight: 26
    readonly property int optionHeight: 26
    readonly property int optionRounding: 8

    readonly property int arcSize: 172
    readonly property real arcThicknessRatio: 0.1
    readonly property real arcStart: -90
    readonly property real arcSpan: 360
    readonly property int nextNameSize: 20
    readonly property int nextTimeSize: 30

    readonly property string timeFormat: "HH:mm"
    readonly property string dayKeyFormat: "yyyy-MM-dd"
    readonly property string placeholder: "\u2014"
    readonly property string coordFormat: "%1, %2"
    readonly property int coordPrecision: 3

    readonly property int searchMaxResults: 5
    readonly property int searchDebounce: 350
    readonly property int searchMinLength: 2
    readonly property int requestTimeout: 8

    readonly property var alertOffsets: [20, 10, 5, 0]
    readonly property int notifyIdBase: 9200
    readonly property int urgentWindow: 20

    readonly property int pillIconSize: 13
    readonly property int dividerWidth: 1
    readonly property real dividerOpacity: 0.25
    readonly property int dividerHeight: 14

    readonly property int saveDebounce: 500
    readonly property string stateFile: "prayer.json"

    readonly property string labelToday: "Today"
    readonly property string labelPlace: "Location"
    readonly property string labelMethod: "Method"
    readonly property string labelAsr: "Asr"
    readonly property string labelHighLat: "High latitude"
    readonly property string labelDetect: "Detect again"
    readonly property string labelSearch: "Search for a city"
    readonly property string labelDetecting: "Detecting\u2026"
    readonly property string labelSearching: "Searching\u2026"
    readonly property string sourcePinned: "Pinned"
    readonly property string sourceDetected: "Detected"
    readonly property string sourceCached: "Cached"
    readonly property string sourceFallback: "Default"
    readonly property string zoneWarning: "Location is %1 but your system clock is %2. Times may be wrong until you change your system timezone."
}
