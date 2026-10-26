import QtQuick

QtObject {
    readonly property int thickness: 8
    readonly property int rounding: 20
    readonly property int fillet: 36
    readonly property int outline: 2
    readonly property real outlineSolidFrom: 0.8
    readonly property real outlineSolidTo: 0.98
    readonly property string outlineShader: "core/shaders/outline.frag.qsb"
}
