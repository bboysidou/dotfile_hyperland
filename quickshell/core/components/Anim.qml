import QtQuick
import qs.core.enums
import qs.core.helpers

NumberAnimation {
    id: root

    property string type: AnimType.standard

    duration: Motion.durationFor(root.type)
    easing.type: Easing.BezierSpline
    easing.bezierCurve: Motion.curveFor(root.type)
}
