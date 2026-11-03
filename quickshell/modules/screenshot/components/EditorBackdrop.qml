import QtQuick
import QtQuick.Shapes

Shape {
    id: root

    required property var colours

    preferredRendererType: Shape.CurveRenderer

    ShapePath {
        strokeColor: "transparent"
        fillGradient: LinearGradient {
            x1: 0
            y1: 0
            x2: root.width
            y2: root.height

            GradientStop {
                position: 0
                color: root.colours[0]
            }

            GradientStop {
                position: 1
                color: root.colours[1]
            }
        }

        PathRectangle {
            x: 0
            y: 0
            width: root.width
            height: root.height
        }
    }
}
