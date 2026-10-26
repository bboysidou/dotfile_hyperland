import QtQuick

QtObject {
    id: root

    property real scale: 1

    readonly property int tiny: Math.round(10 * root.scale)
    readonly property int small: Math.round(11 * root.scale)
    readonly property int normal: Math.round(14 * root.scale)
    readonly property int large: Math.round(16 * root.scale)
}
