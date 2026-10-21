import QtQuick
import qs.core.enums

QtObject {
    readonly property int tileSize: 132
    readonly property int tileRounding: 28
    readonly property int tileSpacing: 24
    readonly property int tileIconSize: 52
    readonly property int tileBorderWidth: 2
    readonly property int labelSize: 15
    readonly property int labelSpacing: 14
    readonly property real selectedScale: 1.08
    readonly property int sectionSpacing: 48
    readonly property int headerSpacing: 6
    readonly property int clockSize: 64
    readonly property int uptimeSize: 16
    readonly property int hintSize: 13
    readonly property real hintOpacity: 0.9
    readonly property real blur: 1.0
    readonly property int blurMax: 64
    readonly property real backgroundDim: 0.55
    readonly property string fadeInType: AnimType.standardLarge
    readonly property string fadeOutType: AnimType.standard
    readonly property string clockFormat: "HH:mm"
    readonly property string uptimeTemplate: "up %1"
    readonly property string uptimeUnknown: "?"
    readonly property string hint: "esc cancel \u00b7 \u21b5 select"
    readonly property string lockLabel: "Lock"
    readonly property string logoutLabel: "Logout"
    readonly property string rebootLabel: "Reboot"
    readonly property string shutdownLabel: "Shutdown"
    readonly property string lockKey: "l"
    readonly property string logoutKey: "o"
    readonly property string rebootKey: "r"
    readonly property string shutdownKey: "s"
}
