import QtQuick

QtObject {
    readonly property string labelOverview: "Overview"
    readonly property string labelBattery: "Battery"
    readonly property string labelHistory: "History"
    readonly property string labelDetails: "Details"
    readonly property string labelCare: "Care"

    readonly property int sectionSpacing: 12
    readonly property int cardPadding: 14
    readonly property int cardSpacing: 10
    readonly property int titleSize: 10
    readonly property real titleLetterSpacing: 1.2
    readonly property int valueSize: 13
    readonly property int detailSize: 11
    readonly property int iconSize: 16

    readonly property int historyInterval: 60000
    readonly property int historyPoints: 96
    readonly property int chartHeight: 44
    readonly property int chartSpacing: 4
    readonly property real chartFillOpacity: 0.18
    readonly property int chartLineWidth: 2
    readonly property string historyCharge: "charge"
    readonly property string historyRate: "rate"
    readonly property var spans: [
        {
            key: "6h",
            label: "6H",
            seconds: 21600
        },
        {
            key: "24h",
            label: "24H",
            seconds: 86400
        },
        {
            key: "7d",
            label: "7D",
            seconds: 604800
        }
    ]
    readonly property string defaultSpan: "24h"
    readonly property int spanWidth: 132
    readonly property string titleHistory: "HISTORY"
    readonly property string titleCharge: "CHARGE"
    readonly property string titleRate: "POWER"
    readonly property string emptyHistory: "UPower has no history for this span yet"
    readonly property string percentRangeTemplate: "%1–%2%"
    readonly property string wattRangeTemplate: "%1–%2 W"

    readonly property int splitInterval: 2000
    readonly property int splitBarHeight: 8
    readonly property int splitBarRounding: 4
    readonly property string titleSplit: "WHERE THE POWER GOES"
    readonly property string labelCpu: "CPU"
    readonly property string labelRest: "Screen, GPU & rest"
    readonly property string wattTemplate: "%1 W"
    readonly property string emptySplit: "Install qs-hwinfo to split CPU power"

    readonly property int chipSpacing: 6
    readonly property int chipPaddingH: 10
    readonly property int chipPaddingV: 5
    readonly property int chipRounding: 10
    readonly property int chipIconSize: 13
    readonly property real chipTint: 0.14
    readonly property string conditionGood: "Good"
    readonly property string conditionTemplate: "Health: %1"
    readonly property string ageYearsTemplate: "%1y %2m old"
    readonly property string ageMonthsTemplate: "%1 months old"
    readonly property int calibrationMargin: 5
    readonly property string labelCalibrate: "Needs a full calibration cycle"

    readonly property int chargerInterval: 5000
    readonly property string titleCharger: "CHARGER"
    readonly property string labelUnplugged: "Not connected"
    readonly property string labelPlugged: "Connected"
    readonly property string usbTemplate: "USB %1"
    readonly property string contractTemplate: "%1 V · %2 A"
    readonly property int chargerDecimals: 1

    readonly property string titleCare: "BATTERY CARE"
    readonly property var limitPresets: [60, 80, 100]
    readonly property int limitHysteresis: 5
    readonly property string limitTemplate: "%1%"
    readonly property string labelLimit: "Charge limit"
    readonly property string labelHold: "Hold charge on AC"
    readonly property string detailHold: "Run from the charger, the battery level stays put"
    readonly property string labelMode: "Charging mode"
    readonly property string behaviourHold: "inhibit-charge"
    readonly property string behaviourAuto: "auto"
    readonly property string attrEnd: "charge_control_end_threshold"
    readonly property string attrStart: "charge_control_start_threshold"
    readonly property string attrBehaviour: "charge_behaviour"
    readonly property string attrTypes: "charge_types"
    readonly property string labelLocked: "Install the qs-battery-perms udev rule to change these"
    readonly property string labelFailed: "The kernel refused the last change"
    readonly property string stateFile: "battery.json"
    readonly property int saveDebounce: 500
}
