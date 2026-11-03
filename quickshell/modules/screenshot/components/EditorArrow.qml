import QtQuick
import QtQuick.Shapes
import qs.core.config
import qs.core.helpers

Shape {
    id: root

    required property var ann
    required property real zoom

    readonly property var head: ({
            length: Appearance.editor.headLength,
            width: Appearance.editor.headWidth,
            min: Appearance.editor.headMin,
            maxRatio: Appearance.editor.headMaxRatio,
            taper: Appearance.editor.pointyTail,
            body: Appearance.editor.pointyBody,
            overlap: Appearance.editor.curveOverlap
        })
    readonly property bool bent: Curve.bent(root.ann)
    readonly property var curve: Curve.arrow(root.ann, root.zoom, root.head)

    preferredRendererType: Shape.CurveRenderer

    ShapePath {
        fillColor: root.bent ? "transparent" : root.ann.color
        strokeColor: "transparent"
        joinStyle: ShapePath.RoundJoin

        PathPolyline {
            path: root.bent ? [] : Ink.arrow(root.ann, root.zoom, root.head)
        }
    }

    ShapePath {
        fillColor: "transparent"
        strokeColor: root.bent ? root.ann.color : "transparent"
        strokeWidth: root.ann.width * root.zoom
        capStyle: ShapePath.FlatCap
        startX: root.curve.start.x
        startY: root.curve.start.y

        PathQuad {
            x: root.curve.end.x
            y: root.curve.end.y
            controlX: root.curve.control.x
            controlY: root.curve.control.y
        }
    }

    ShapePath {
        fillColor: root.bent ? root.ann.color : "transparent"
        strokeColor: "transparent"
        joinStyle: ShapePath.RoundJoin

        PathMultiline {
            paths: root.bent ? root.curve.heads : []
        }
    }
}
