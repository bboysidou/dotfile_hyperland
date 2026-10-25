import QtQuick

QtObject {
    readonly property string stateFile: "power-profiles.json"
    readonly property int saveDebounce: 500
    readonly property string ac: "ac"
    readonly property string battery: "battery"
    readonly property int batteryPollFactor: 3
    readonly property string batteryScript: "hl.config({ decoration = { inactive_opacity = 1.0, blur = { enabled = false }, shadow = { enabled = false } } })"
}
