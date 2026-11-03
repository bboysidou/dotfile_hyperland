import QtQuick
import QtQuick.Shapes
import qs.core.helpers

Shape {
    id: root

    required property var ann
    required property real zoom

    preferredRendererType: Shape.CurveRenderer

    ShapePath {
        fillColor: "transparent"
        strokeColor: root.ann.color
        strokeWidth: root.ann.width * root.zoom
        capStyle: ShapePath.RoundCap

        PathPolyline {
            path: [Ink.point(root.ann.x1, root.ann.y1, root.zoom), Ink.point(root.ann.x2, root.ann.y2, root.zoom)]
        }
    }
}
