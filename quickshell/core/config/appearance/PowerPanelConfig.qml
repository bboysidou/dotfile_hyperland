import QtQuick

QtObject {
    readonly property int sectionSpacing: 14
    readonly property int ringSize: 196
    readonly property real ringRadiusRatio: 0.44
    readonly property real ringThicknessRatio: 0.055
    readonly property var haloRatios: [1.5, 1.22]
    readonly property real haloOpacity: 0.07
    readonly property int percentSize: 44
    readonly property int percentGlyphSize: 26
    readonly property int heroTextSpacing: 4
    readonly property int statusSize: 11
    readonly property real statusLetterSpacing: 1.5
    readonly property int warningPercent: 20
    readonly property int criticalPercent: 10
    readonly property int timeTileSize: 44
    readonly property int timeTileRounding: 10
    readonly property int timeDigitSize: 18
    readonly property int timeUnitSize: 8
    readonly property int timeSeparatorSize: 16
    readonly property int timeSpacing: 8
    readonly property int sliderCardPadding: 14
    readonly property int sliderRowSpacing: 14
    readonly property int sliderIconSize: 18
    readonly property int brightnessMin: 5
    readonly property int backlightDebounce: 30
    readonly property int backlightRefresh: 60
    readonly property int ddcDebounce: 250
    readonly property int actionHeight: 64
    readonly property int actionRounding: 14
    readonly property int actionIconSize: 22
    readonly property int actionSpacing: 8
    readonly property int cardRounding: 14
    readonly property int secondsPerHour: 3600
    readonly property int secondsPerMinute: 60
    readonly property int timeDigits: 2
    readonly property string timeUnknown: "--"
    readonly property string hoursLabel: "HR"
    readonly property string minutesLabel: "MIN"
    readonly property string timeSeparator: ":"
    readonly property string labelCharging: "CHARGING"
    readonly property string labelDischarging: "ON BATTERY"
    readonly property string labelFull: "FULLY CHARGED"
    readonly property string labelNotCharging: "NOT CHARGING"
    readonly property string labelAc: "AC POWER"
    readonly property string labelPerformance: "Perform"
    readonly property string labelBalanced: "Balance"
    readonly property string labelSaver: "Saver"
    readonly property string labelTitle: "Power"
    readonly property string profileTemplate: "%1  %2"
    readonly property string profilePerformance: "performance"
    readonly property string profileBalanced: "balanced"
    readonly property string profileSaver: "saver"
}
