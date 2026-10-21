import QtQuick

QtObject {
    readonly property var levels: [0, 1, 3, 6, 8, 12]
    readonly property real opacity: 0.7
    readonly property real blurScale: 5
    readonly property real blurExponent: 0.7
    readonly property real spreadScale: 0.3
    readonly property real spreadCurve: 0.1
    readonly property int panel: 3
}
