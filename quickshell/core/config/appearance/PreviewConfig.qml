import QtQuick

QtObject {
    readonly property bool enabled: true
    readonly property int width: 300
    readonly property int maxHeight: 220
    readonly property int thumbScale: 2
    readonly property int timeout: 6000
    readonly property int border: 1
    readonly property int padding: 6
    readonly property real barOpacity: 0.82
    readonly property int barPadding: 6
    readonly property int barSpacing: 2
    readonly property int barRounding: 12
    readonly property real pinScreenRatio: 0.4
    readonly property int pinCascade: 32
    readonly property real pinZoomStep: 0.1
    readonly property real pinMinZoom: 0.2
    readonly property real pinMaxZoom: 4
    readonly property int pinRounding: 10
    readonly property int pinBorder: 2
}
