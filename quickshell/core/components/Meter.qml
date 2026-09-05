import QtQuick
import qs.core.config
import qs.core.helpers

StyledRect {
    id: root

    property real value: 0
    property bool vertical: false
    property color fillColour: Colours.highlight
    property int minFill: Appearance.bar.sliderFillMinWidth
    property int rounding: Appearance.bar.sliderRounding

    color: Colours.trough
    radius: root.rounding

    StyledRect {
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.right: root.vertical ? parent.right : undefined
        anchors.top: root.vertical ? undefined : parent.top

        width: root.vertical ? undefined : Math.max(root.minFill, Num.clamp01(root.value) * parent.width)
        height: root.vertical ? Math.max(root.minFill, Num.clamp01(root.value) * parent.height) : undefined
        color: root.fillColour
        radius: root.rounding
    }
}
