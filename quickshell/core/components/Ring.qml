import QtQuick
import QtQuick.Shapes
import qs.core.config
import qs.core.enums

Item {
    id: root

    property real value: 0
    property color colour: Colours.accent
    property color track: Colours.ringTrack
    property real radiusRatio: Appearance.bar.ringRadiusRatio
    property real thicknessRatio: Appearance.bar.ringThicknessRatio
    property real startAngle: -90
    property real span: 360
    property int capStyle: ShapePath.FlatCap

    readonly property real radius: width * root.radiusRatio
    readonly property real thickness: width * root.thicknessRatio

    implicitWidth: Appearance.bar.ringSize
    implicitHeight: Appearance.bar.ringSize

    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            strokeColor: root.track
            strokeWidth: root.thickness
            fillColor: "transparent"
            capStyle: root.capStyle

            PathAngleArc {
                centerX: root.width / 2
                centerY: root.height / 2
                radiusX: root.radius
                radiusY: root.radius
                startAngle: root.startAngle
                sweepAngle: root.span
            }
        }

        ShapePath {
            strokeColor: root.colour
            strokeWidth: root.thickness
            fillColor: "transparent"
            capStyle: root.capStyle

            PathAngleArc {
                centerX: root.width / 2
                centerY: root.height / 2
                radiusX: root.radius
                radiusY: root.radius
                startAngle: root.startAngle
                sweepAngle: root.span * root.value

                Behavior on sweepAngle {
                    Anim {
                        type: AnimType.standardSmall
                    }
                }
            }
        }
    }
}
