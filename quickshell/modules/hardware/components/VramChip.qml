import QtQuick
import qs.core.components
import qs.core.config

Row {
    id: root

    property bool upperUsed: false
    property bool lowerUsed: false

    readonly property real half: (Appearance.hardware.gpuChipHeight - Appearance.hardware.outlineWidth * 2 - Appearance.hardware.chipDivider) / 2

    spacing: Appearance.spacing.none

    PinRail {
        anchors.verticalCenter: parent.verticalCenter

        vertical: true
        span: Appearance.hardware.gpuChipHeight
    }

    Rectangle {
        implicitWidth: Appearance.hardware.gpuChipWidth
        implicitHeight: Appearance.hardware.gpuChipHeight

        color: Colours.surface
        radius: Appearance.hardware.dieRounding
        border.width: Appearance.hardware.outlineWidth
        border.color: Colours.gauge

        Column {
            anchors.fill: parent
            anchors.margins: Appearance.hardware.outlineWidth

            spacing: Appearance.hardware.chipDivider

            Rectangle {
                width: parent.width
                height: root.half

                radius: Appearance.rounding.tiny
                color: root.upperUsed ? Colours.gpu : Colours.trough

                Behavior on color {
                    CAnim {}
                }
            }

            Rectangle {
                width: parent.width
                height: root.half

                radius: Appearance.rounding.tiny
                color: root.lowerUsed ? Colours.gpu : Colours.trough

                Behavior on color {
                    CAnim {}
                }
            }
        }
    }

    PinRail {
        anchors.verticalCenter: parent.verticalCenter

        vertical: true
        span: Appearance.hardware.gpuChipHeight
    }
}
