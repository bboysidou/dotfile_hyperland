import QtQuick

QtObject {
    readonly property int autoPercent: 20
    readonly property int brightnessCap: 40
    readonly property real minRefreshRate: 59
    readonly property var internalPrefixes: ["eDP", "LVDS", "DSI"]
    readonly property string hyprScript: "hl.config({ animations = { enabled = false }, decoration = { blur = { enabled = false }, shadow = { enabled = false } } })"
    readonly property string reloadEvent: "configreloaded"
    readonly property int detailSize: 11
    readonly property string label: "Low power"
    readonly property string detail: "Saver profile, no animations or blur, 60 Hz, dimmer screen"
}
