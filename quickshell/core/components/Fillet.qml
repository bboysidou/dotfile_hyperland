import QtQuick
import QtQuick.Shapes
import qs.core.config
import qs.core.enums

Shape {
    id: root

    readonly property real kappa: 0.5522847498

    property real size: Appearance.border.fillet
    property color colour: Colours.bar
    property string origin: Corner.topLeft

    readonly property real signX: root.origin === Corner.topLeft || root.origin === Corner.bottomLeft ? 1 : -1
    readonly property real signY: root.origin === Corner.topLeft || root.origin === Corner.topRight ? 1 : -1
    readonly property real originX: root.signX > 0 ? 0 : root.size
    readonly property real originY: root.signY > 0 ? 0 : root.size

    readonly property real spanX: root.originX + root.size * root.signX
    readonly property real spanY: root.originY + root.size * root.signY
    readonly property real bendX: root.originX + root.size * root.kappa * root.signX
    readonly property real bendY: root.originY + root.size * root.kappa * root.signY

    implicitWidth: root.size
    implicitHeight: root.size

    preferredRendererType: Shape.CurveRenderer

    ShapePath {
        fillColor: root.colour
        strokeWidth: -1

        startX: root.spanX
        startY: root.originY

        PathLine {
            x: root.spanX
            y: root.spanY
        }
        PathLine {
            x: root.originX
            y: root.spanY
        }
        PathCubic {
            control1X: root.bendX
            control1Y: root.spanY
            control2X: root.spanX
            control2Y: root.bendY
            x: root.spanX
            y: root.originY
        }
    }
}
