import QtQuick

QtObject {
    readonly property int maxWidth: 1240
    readonly property int sideMargin: 48
    readonly property int padding: 24
    readonly property real scaleFrom: 0.96
    readonly property int sectionSpacing: 16
    readonly property int zoneSpacing: 10
    readonly property int zonePadding: 12
    readonly property int zoneRounding: 14
    readonly property int zoneMinHeight: 96
    readonly property int trayMinHeight: 56
    readonly property int chipSpacing: 6
    readonly property int chipHeight: 30
    readonly property int chipPadding: 12
    readonly property int chipRounding: 999
    readonly property int chipTextSize: 12
    readonly property int chipGlyphSize: 12
    readonly property int chipGlyphSpacing: 6
    readonly property int chipBorder: 2
    readonly property real draggedOpacity: 0.3
    readonly property real offOpacity: 0.55
    readonly property int markerWidth: 3
    readonly property int dragThreshold: 6
    readonly property int labelSpacing: 8
    readonly property string labelTitle: "Bar layout"
    readonly property string labelOffTray: "Off"
    readonly property string labelReset: "Reset"
    readonly property string labelDone: "Done"
    readonly property string labelHint: "Drag widgets between zones, or into Off to remove them from every bar. Right-click toggles off. Arrows select, Shift+arrows move, Delete toggles off. Per-monitor visibility lives in Display › Bar."
}
