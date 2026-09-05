import QtQuick
import QtQuick.Shapes
import qs.core.config

Shape {
    id: root

    property real thickness: Appearance.border.thickness
    property real topThickness: root.thickness
    property real rounding: Appearance.border.rounding
    property color colour: Colours.bar

    readonly property real edgeLeft: root.thickness
    readonly property real edgeRight: root.width - root.thickness
    readonly property real edgeTop: root.topThickness
    readonly property real edgeBottom: root.height - root.thickness
    readonly property real innerRadius: Math.max(0, Math.min(root.rounding, (root.edgeRight - root.edgeLeft) / 2, (root.edgeBottom - root.edgeTop) / 2))

    preferredRendererType: Shape.CurveRenderer

    ShapePath {
        fillColor: root.colour
        strokeWidth: -1
        fillRule: ShapePath.OddEvenFill

        startX: 0
        startY: 0

        PathLine {
            x: root.width
            y: 0
        }
        PathLine {
            x: root.width
            y: root.height
        }
        PathLine {
            x: 0
            y: root.height
        }
        PathLine {
            x: 0
            y: 0
        }

        PathMove {
            x: root.edgeLeft + root.innerRadius
            y: root.edgeTop
        }
        PathLine {
            x: root.edgeRight - root.innerRadius
            y: root.edgeTop
        }
        PathArc {
            x: root.edgeRight
            y: root.edgeTop + root.innerRadius
            radiusX: root.innerRadius
            radiusY: root.innerRadius
        }
        PathLine {
            x: root.edgeRight
            y: root.edgeBottom - root.innerRadius
        }
        PathArc {
            x: root.edgeRight - root.innerRadius
            y: root.edgeBottom
            radiusX: root.innerRadius
            radiusY: root.innerRadius
        }
        PathLine {
            x: root.edgeLeft + root.innerRadius
            y: root.edgeBottom
        }
        PathArc {
            x: root.edgeLeft
            y: root.edgeBottom - root.innerRadius
            radiusX: root.innerRadius
            radiusY: root.innerRadius
        }
        PathLine {
            x: root.edgeLeft
            y: root.edgeTop + root.innerRadius
        }
        PathArc {
            x: root.edgeLeft + root.innerRadius
            y: root.edgeTop
            radiusX: root.innerRadius
            radiusY: root.innerRadius
        }
    }
}
