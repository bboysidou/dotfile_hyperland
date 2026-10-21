import QtQuick

QtObject {
    readonly property var standard: [0.2, 0, 0, 1, 1, 1]
    readonly property var standardAccel: [0.3, 0, 1, 1, 1, 1]
    readonly property var standardDecel: [0, 0, 0, 1, 1, 1]
    readonly property var emphasized: [0.05, 0, 0.133333, 0.06, 0.166667, 0.4, 0.208333, 0.82, 0.25, 1, 1, 1]
    readonly property var emphasizedAccel: [0.3, 0, 0.8, 0.15, 1, 1]
    readonly property var emphasizedDecel: [0.05, 0.7, 0.1, 1, 1, 1]
    readonly property var fastSpatial: [0.42, 1.67, 0.21, 0.9, 1, 1]
    readonly property var defaultSpatial: [0.38, 1.21, 0.22, 1, 1, 1]
    readonly property var slowSpatial: [0.39, 1.29, 0.35, 0.98, 1, 1]
    readonly property var fastEffects: [0.31, 0.94, 0.34, 1, 1, 1]
    readonly property var defaultEffects: [0.34, 0.8, 0.34, 1, 1, 1]
    readonly property var slowEffects: [0.34, 0.88, 0.34, 1, 1, 1]
}
