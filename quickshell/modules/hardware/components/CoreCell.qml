import QtQuick
import qs.core.components
import qs.core.config
import qs.core.enums
import qs.core.helpers

Rectangle {
    id: root

    property real load: 0

    readonly property color tone: Tone.usage(root.load * Appearance.scale.percent, Colours.cpu)
    readonly property bool hot: root.load >= Appearance.hardware.cpuActiveLoad
    readonly property real inner: root.height - Appearance.hardware.cellBorderWidth * 2

    implicitWidth: Appearance.hardware.cpuCellSize
    implicitHeight: Appearance.hardware.cpuCellSize

    radius: Appearance.hardware.cellRounding
    color: Colours.trough
    border.width: Appearance.hardware.cellBorderWidth
    border.color: root.hot ? root.tone : Colours.border

    Behavior on border.color {
        CAnim {}
    }

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: Appearance.hardware.cellBorderWidth

        height: root.inner * Math.max(root.load, Appearance.hardware.cpuIdleFill)
        radius: Math.max(0, root.radius - Appearance.hardware.cellBorderWidth)
        color: root.tone
        opacity: Appearance.hardware.cellFillOpacity

        Behavior on height {
            Anim {
                type: AnimType.standard
            }
        }

        Behavior on color {
            CAnim {}
        }
    }

    Rectangle {
        anchors.centerIn: parent

        implicitWidth: Appearance.hardware.cpuCoreDot
        implicitHeight: Appearance.hardware.cpuCoreDot

        radius: Appearance.rounding.full
        color: root.hot ? root.tone : "transparent"
        border.width: Appearance.hardware.cellBorderWidth
        border.color: root.tone

        Behavior on color {
            CAnim {}
        }
    }
}
