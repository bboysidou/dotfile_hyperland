pragma ComponentBehavior: Bound

import QtQuick
import qs.core.components
import qs.core.config
import qs.services

Item {
    id: root

    property bool active: true
    property real innerRadius: 0
    property real magnitude: Appearance.dash.visualiserMagnitude
    property color colour: Colours.accent

    readonly property int count: Cava.bars
    readonly property real barWidth: 2 * Math.PI * root.innerRadius / root.count * Appearance.dash.visualiserBarWidthRatio

    Repeater {
        model: root.count

        Item {
            id: spoke

            required property int index

            readonly property real value: root.active ? (Cava.values[spoke.index] ?? 0) : 0

            anchors.centerIn: parent

            width: 0
            height: 0
            rotation: spoke.index * 360 / root.count

            StyledRect {
                x: -root.barWidth / 2
                y: root.innerRadius

                width: root.barWidth
                height: Appearance.dash.visualiserMinBar + spoke.value * root.magnitude
                radius: width / 2
                color: root.colour
            }
        }
    }
}
