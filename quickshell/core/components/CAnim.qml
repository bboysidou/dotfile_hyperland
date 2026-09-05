import QtQuick
import qs.core.enums
import qs.core.helpers

ColorAnimation {
    id: root

    property string type: AnimType.slowEffects

    duration: Motion.durationFor(root.type)
    easing.type: Easing.BezierSpline
    easing.bezierCurve: Motion.curveFor(root.type)
}
