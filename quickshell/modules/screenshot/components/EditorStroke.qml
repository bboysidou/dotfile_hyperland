import QtQuick
import QtQuick.Shapes
import qs.core.helpers

Shape {
    id: root

    required property var ann
    required property real zoom

    preferredRendererType: Shape.CurveRenderer
    opacity: root.ann.opacity

    ShapePath {
        fillColor: "transparent"
        strokeColor: root.ann.color
        strokeWidth: root.ann.width * root.zoom
        capStyle: ShapePath.RoundCap
        joinStyle: ShapePath.RoundJoin

        PathPolyline {
            path: root.ann.points.map(p => Ink.point(p.x, p.y, root.zoom))
        }
    }
}
