import QtQuick
import QtQuick.Shapes
import qs.core.helpers

Shape {
    id: root

    required property var ann
    required property real zoom

    readonly property var box: Ink.box(root.ann)

    preferredRendererType: Shape.CurveRenderer

    ShapePath {
        fillColor: root.ann.filled ? root.ann.color : "transparent"
        strokeColor: root.ann.color
        strokeWidth: root.ann.width * root.zoom

        PathAngleArc {
            centerX: (root.box.x + root.box.width / 2) * root.zoom
            centerY: (root.box.y + root.box.height / 2) * root.zoom
            radiusX: root.box.width / 2 * root.zoom
            radiusY: root.box.height / 2 * root.zoom
            startAngle: 0
            sweepAngle: 360
        }
    }
}
