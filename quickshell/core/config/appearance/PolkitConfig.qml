import QtQuick

QtObject {
    readonly property int width: 420
    readonly property int rounding: 16
    readonly property int borderWidth: 2
    readonly property int padding: 20
    readonly property int spacing: 12
    readonly property int iconSize: 32
    readonly property int titleSize: 16
    readonly property int bodySize: 13
    readonly property int fieldHeight: 40
    readonly property int fieldRounding: 1000
    readonly property int fieldPaddingH: 20
    readonly property int dotSize: 10
    readonly property int dotSpacing: 8
    readonly property int actionSpacing: 10
    readonly property int actionPaddingV: 6
    readonly property int actionPaddingH: 14
    readonly property int actionRounding: 10
    readonly property real scaleFrom: 0.96
    readonly property string title: "Authentication required"
    readonly property string confirmLabel: "Authenticate"
    readonly property string cancelLabel: "Cancel"
}
