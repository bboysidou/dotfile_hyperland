pragma ComponentBehavior: Bound

import QtQuick
import qs.core.config

Item {
    id: root

    property real span: 0
    property bool vertical: false
    property color colour: Colours.gauge

    readonly property real step: Appearance.hardware.pinThickness + Appearance.hardware.pinGap
    readonly property int count: Math.max(0, Math.floor((root.span + Appearance.hardware.pinGap) / root.step))
    readonly property real extent: Math.max(0, root.count * root.step - Appearance.hardware.pinGap)

    implicitWidth: root.vertical ? Appearance.hardware.pinLength : root.extent
    implicitHeight: root.vertical ? root.extent : Appearance.hardware.pinLength

    Repeater {
        model: root.count

        Rectangle {
            required property int index

            x: root.vertical ? 0 : index * root.step
            y: root.vertical ? index * root.step : 0
            width: root.vertical ? Appearance.hardware.pinLength : Appearance.hardware.pinThickness
            height: root.vertical ? Appearance.hardware.pinThickness : Appearance.hardware.pinLength

            radius: Appearance.hardware.pinThickness / 2
            color: root.colour
        }
    }
}
