import QtQuick

QtObject {
    readonly property int sectionSpacing: 14
    readonly property int percentSize: 44
    readonly property int percentGlyphSize: 26
    readonly property int heroTextSpacing: 4
    readonly property int statusSize: 11
    readonly property real statusLetterSpacing: 1.5
    readonly property int warningPercent: 50
    readonly property int criticalPercent: 25
    readonly property int ringWaveSteps: 240
    readonly property real ringWaveTaper: 0.5
    readonly property var ringWaves: [
        {
            amplitude: 6,
            rate: 1.1,
            waves: 12,
            width: 7,
            alpha: 0.2
        },
        {
            amplitude: 4.5,
            rate: -0.9,
            waves: 16,
            width: 2.4,
            alpha: 0.55
        },
        {
            amplitude: 4,
            rate: 0.7,
            waves: 14,
            width: 1.3,
            alpha: 0.9
        }
    ]
    readonly property real ringStartAngle: -90
    readonly property real coreRingScale: 1.95
    readonly property real coreRingRadiusRatio: 0.4
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
    readonly property int batteryInfoInterval: 30000
    readonly property int statColumns: 2
    readonly property int statSpacing: 12
    readonly property int statLabelSize: 10
    readonly property real statLetterSpacing: 1.2
    readonly property int statValueSize: 14
    readonly property int statDecimals: 1
    readonly property string statDraw: "DRAW"
    readonly property string statInput: "CHARGE RATE"
    readonly property string statEnergy: "ENERGY"
    readonly property string statHealth: "HEALTH"
    readonly property string statRuntime: "FULL CHARGE LASTS"
    readonly property string statCycles: "CYCLES"
    readonly property string statVoltage: "VOLTAGE"
    readonly property string statTemperature: "TEMPERATURE"
    readonly property string statLimit: "CHARGE LIMIT"
    readonly property string statCell: "CELL"
    readonly property string statCurrent: "CURRENT"
    readonly property string statVendorHealth: "VENDOR HEALTH"
    readonly property string statResistance: "RESISTANCE"
    readonly property string statSerial: "SERIAL"
    readonly property string ampTemplate: "%1 A"
    readonly property string milliOhmTemplate: "%1 mΩ"
    readonly property string limitRangeTemplate: "%1–%2%"
    readonly property string wattTemplate: "%1 W"
    readonly property string energyTemplate: "%1 / %2 Wh"
    readonly property string healthTemplate: "%1% of %2 Wh"
    readonly property string percentTemplate: "%1%"
    readonly property string voltTemplate: "%1 V"
    readonly property string celsiusTemplate: "%1 \u00b0C"
}
