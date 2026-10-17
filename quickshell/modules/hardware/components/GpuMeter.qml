pragma ComponentBehavior: Bound

import QtQuick
import qs.core.components
import qs.core.config
import qs.core.helpers

Column {
    id: root

    property string glyph: ""
    property real value: 0
    property color colour: Colours.gpu

    readonly property int bars: Appearance.hardware.gpuBars
    readonly property int lit: root.value > 0 ? Math.ceil(Num.clamp01(root.value) * root.bars) : 0
    readonly property color tone: Tone.usage(root.value * Appearance.scale.percent, root.colour)
    readonly property real taper: (Appearance.hardware.gpuBarMax - Appearance.hardware.gpuBarMin) / Math.max(1, root.bars - 1)

    spacing: Appearance.hardware.gpuBarSpacing

    Icon {
        anchors.horizontalCenter: parent.horizontalCenter

        text: root.glyph
        color: root.lit > 0 ? root.tone : Colours.textMuted
        font.pixelSize: Appearance.hardware.gpuIconSize
    }

    Repeater {
        model: root.bars

        Rectangle {
            required property int index

            readonly property bool on: index >= root.bars - root.lit

            implicitWidth: Appearance.hardware.gpuBarWidth
            implicitHeight: Appearance.hardware.gpuBarMax - index * root.taper

            radius: Appearance.rounding.tiny
            color: on ? root.tone : Colours.trough

            Behavior on color {
                CAnim {}
            }
        }
    }
}
