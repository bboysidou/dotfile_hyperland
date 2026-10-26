import QtQuick

QtObject {
    readonly property string env: "QS_IDLE"
    readonly property string envEnabled: "1"
    readonly property string stateFile: "idle.json"
    readonly property int saveDebounce: 400
    readonly property int rearmDelay: 100
    readonly property int lockSeconds: 300
    readonly property int screenOffSeconds: 330
    readonly property int suspendSeconds: 900
    readonly property int minSeconds: 30
    readonly property int maxSeconds: 7200
    readonly property var steps: [[600, 30], [3600, 300], [7200, 900]]
    readonly property int stepperWidth: 110
    readonly property string labelEnabled: "Idle actions"
    readonly property string labelLock: "Lock screen"
    readonly property string labelScreenOff: "Screen off"
    readonly property string labelSuspend: "Suspend"
    readonly property string labelBatteryOnly: "On battery only"
    readonly property string hintDisabled: "Idle actions are off. The screen stays on until you lock it."
    readonly property string hintActive: "Timers count from the last keyboard or mouse input."
    readonly property string secondsTemplate: "%1 s"
    readonly property string minutesTemplate: "%1 min"
    readonly property string minutesSecondsTemplate: "%1 min %2 s"
    readonly property string hoursTemplate: "%1 h"
    readonly property string hoursMinutesTemplate: "%1 h %2 min"
}
