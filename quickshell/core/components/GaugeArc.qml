import QtQuick
import QtQuick.Shapes
import qs.core.config
import qs.core.enums
import qs.core.helpers

Item {
    id: root

    property real value: 0
    property real startAngle: 0
    property real span: 180
    property real strokeWidth: Appearance.gauge.size * Appearance.gauge.strokeRatio
    property real gapSpacing: Appearance.gauge.size * Appearance.gauge.spacingRatio
    property color fgColour: Colours.accent
    property color bgColour: Qt.alpha(Colours.accent, Appearance.gauge.trackOpacity)

    readonly property real size: Math.min(width, height)
    readonly property real arcRadius: (root.size - root.strokeWidth) / 2

    property real trimStart: 0
    property real trimEnd: 0

    readonly property real gapAngle: ((root.gapSpacing + root.strokeWidth) / (root.arcRadius || 1)) * (90 / Math.PI)
    readonly property real trackStart: root.startAngle + root.gapAngle + root.trimStart
    readonly property real trackSpan: Math.max(0, root.span - root.gapAngle * 2 - root.trimStart - root.trimEnd)

    property real clampedVal: Num.clamp01(root.value)

    Behavior on clampedVal {
        Anim {
            type: AnimType.standard
        }
    }

    Shape {
        anchors.fill: parent

        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            fillColor: "transparent"
            strokeColor: root.bgColour
            strokeWidth: root.strokeWidth
            capStyle: ShapePath.RoundCap

            PathAngleArc {
                centerX: root.size / 2
                centerY: root.size / 2
                radiusX: root.arcRadius
                radiusY: root.arcRadius
                startAngle: root.trackStart
                sweepAngle: root.trackSpan
            }

            Behavior on strokeColor {
                CAnim {}
            }
        }

        ShapePath {
            fillColor: "transparent"
            strokeColor: root.fgColour
            strokeWidth: root.strokeWidth
            capStyle: ShapePath.RoundCap

            PathAngleArc {
                centerX: root.size / 2
                centerY: root.size / 2
                radiusX: root.arcRadius
                radiusY: root.arcRadius
                startAngle: root.trackStart
                sweepAngle: root.trackSpan * root.clampedVal
            }

            Behavior on strokeColor {
                CAnim {}
            }
        }
    }
}
