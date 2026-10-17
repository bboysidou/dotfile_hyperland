pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Shapes
import qs.core.components
import qs.core.config

Item {
    id: root

    property var segments: []

    readonly property real stroke: Appearance.hardware.outlineWidth
    readonly property real inset: root.stroke / 2
    readonly property real boardHeight: root.height - Appearance.hardware.dimmPinHeight
    readonly property real notch: Appearance.hardware.dimmNotchRadius
    readonly property real notchY: Appearance.hardware.dimmNotchOffset
    readonly property real corner: Appearance.hardware.outlineRounding
    readonly property real edgeRight: root.width - root.inset
    readonly property real edgeBottom: root.boardHeight - root.inset
    readonly property int count: Appearance.hardware.dimmSegments
    readonly property int pins: Appearance.hardware.dimmPins
    readonly property int keyPin: Math.round(root.pins * Appearance.hardware.dimmKeyPosition)
    readonly property real pinWidth: (root.width - root.corner * 2 - Appearance.hardware.dimmPinSpacing * (root.pins - 1)) / root.pins

    function colourAt(index: int): color {
        const midpoint = (index + 0.5) / root.count;
        let edge = 0;

        for (const segment of root.segments) {
            edge += segment.fraction;
            if (midpoint < edge)
                return segment.colour;
        }

        return Colours.trough;
    }

    implicitHeight: Appearance.hardware.dimmArtHeight

    DotGrid {
        x: root.notch
        y: root.stroke * 2
        width: root.width - root.notch * 2
        height: root.boardHeight - root.stroke * 4

        colour: Colours.circuit
    }

    Shape {
        anchors.fill: parent

        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            fillColor: "transparent"
            strokeColor: Colours.gauge
            strokeWidth: root.stroke

            startX: root.inset + root.corner
            startY: root.inset

            PathLine {
                x: root.edgeRight - root.corner
                y: root.inset
            }
            PathArc {
                x: root.edgeRight
                y: root.inset + root.corner
                radiusX: root.corner
                radiusY: root.corner
            }
            PathLine {
                x: root.edgeRight
                y: root.notchY - root.notch
            }
            PathArc {
                x: root.edgeRight
                y: root.notchY + root.notch
                radiusX: root.notch
                radiusY: root.notch
                direction: PathArc.Counterclockwise
            }
            PathLine {
                x: root.edgeRight
                y: root.edgeBottom
            }
            PathLine {
                x: root.inset
                y: root.edgeBottom
            }
            PathLine {
                x: root.inset
                y: root.notchY + root.notch
            }
            PathArc {
                x: root.inset
                y: root.notchY - root.notch
                radiusX: root.notch
                radiusY: root.notch
                direction: PathArc.Counterclockwise
            }
            PathLine {
                x: root.inset
                y: root.inset + root.corner
            }
            PathArc {
                x: root.inset + root.corner
                y: root.inset
                radiusX: root.corner
                radiusY: root.corner
            }
        }
    }

    Rectangle {
        anchors.centerIn: bar

        width: bar.width + Appearance.hardware.barFrame * 2
        height: bar.height + Appearance.hardware.barFrame * 2

        color: Colours.surface
        radius: Appearance.rounding.tiny
    }

    Row {
        id: bar

        x: root.notch * 2
        y: (root.boardHeight - height) / 2
        width: root.width - root.notch * 4

        spacing: Appearance.hardware.dimmSegmentSpacing

        Repeater {
            model: root.count

            Rectangle {
                required property int index

                width: (bar.width - bar.spacing * (root.count - 1)) / root.count
                height: Appearance.hardware.dimmSegmentHeight

                color: root.colourAt(index)

                Behavior on color {
                    CAnim {}
                }
            }
        }
    }

    Repeater {
        model: root.pins

        Rectangle {
            required property int index

            x: root.corner + index * (root.pinWidth + Appearance.hardware.dimmPinSpacing)
            y: root.boardHeight
            width: root.pinWidth
            height: Appearance.hardware.dimmPinHeight - root.stroke

            visible: index !== root.keyPin
            color: "transparent"
            border.width: Appearance.hardware.cellBorderWidth
            border.color: Colours.gauge
        }
    }
}
