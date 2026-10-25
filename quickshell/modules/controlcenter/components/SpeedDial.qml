pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import qs.core.components
import qs.core.config
import qs.core.constants
import qs.core.helpers

Item {
    id: root

    property real value: 0
    property color accent: Colours.accent
    property real hueShift: 0
    property string glyph: ""
    property bool live: false

    readonly property var config: Appearance.speedTest
    readonly property real size: root.config.dialSize
    readonly property real centre: root.size / 2
    readonly property real arcRadius: (root.size - root.config.strokeWidth) / 2
    readonly property real labelRadius: root.arcRadius - root.config.strokeWidth / 2 - root.config.tickInset
    readonly property real needleInner: root.centre + root.arcRadius * root.config.needleInner
    readonly property real needleOuter: root.centre + root.arcRadius * root.config.needleOuter
    readonly property real tipHalf: root.config.needleTipWidth / 2
    readonly property real baseHalf: root.config.needleBaseWidth / 2
    readonly property color tail: Colours.shade(Colours.hueShift(root.accent, root.hueShift), root.config.tailLightness)

    property real peak: 0
    property real shown: root.value
    readonly property var ticks: root.config.scales.find(scale => root.peak <= scale[scale.length - 1]) ?? root.config.scales[root.config.scales.length - 1]
    readonly property bool giga: root.ticks[root.ticks.length - 1] > Units.bitsPerKilo
    readonly property real progress: root.fraction(root.shown)
    readonly property var reading: Fmt.bitrate(root.shown, root.config.valueDecimals)

    function fraction(mbps: real): real {
        const ticks = root.ticks;
        const last = ticks.length - 1;

        if (mbps <= ticks[0])
            return 0;
        if (mbps >= ticks[last])
            return 1;

        const segment = ticks.findIndex((tick, index) => index < last && mbps < ticks[index + 1]);
        const within = (mbps - ticks[segment]) / (ticks[segment + 1] - ticks[segment]);
        return (segment + within) / last;
    }

    function angleAt(progress: real): real {
        return root.config.startAngle + root.config.span * progress;
    }

    function tickLabel(mbps: real): string {
        return root.giga && mbps >= Units.bitsPerKilo ? `${mbps / Units.bitsPerKilo}${root.config.gigaSuffix}` : String(mbps);
    }

    onValueChanged: root.peak = root.value > 0 ? Math.max(root.peak, root.value) : 0

    implicitWidth: root.size
    implicitHeight: root.size + root.config.footerDrop

    Behavior on shown {
        NumberAnimation {
            duration: root.config.valueDuration
            easing.type: Easing.OutCubic
        }
    }

    Shape {
        anchors.fill: parent

        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            fillColor: "transparent"
            strokeColor: Colours.trough
            strokeWidth: root.config.strokeWidth
            capStyle: ShapePath.RoundCap

            PathAngleArc {
                centerX: root.centre
                centerY: root.centre
                radiusX: root.arcRadius
                radiusY: root.arcRadius
                startAngle: root.config.startAngle
                sweepAngle: root.config.span
            }
        }
    }

    Shape {
        anchors.fill: parent

        visible: root.progress > 0
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            fillColor: "transparent"
            strokeWidth: root.config.strokeWidth
            capStyle: ShapePath.RoundCap

            strokeGradient: ConicalGradient {
                centerX: root.centre
                centerY: root.centre
                angle: root.config.gradientAngle

                GradientStop {
                    position: 0
                    color: root.accent
                }
                GradientStop {
                    position: root.config.gradientHead
                    color: root.accent
                }
                GradientStop {
                    position: root.config.gradientTail
                    color: root.tail
                }
                GradientStop {
                    position: 1
                    color: root.tail
                }
            }

            PathAngleArc {
                centerX: root.centre
                centerY: root.centre
                radiusX: root.arcRadius
                radiusY: root.arcRadius
                startAngle: root.config.startAngle
                sweepAngle: root.config.span * root.progress
            }
        }
    }

    Repeater {
        model: root.ticks

        StyledText {
            id: tick

            required property real modelData
            required property int index

            readonly property real radians: root.angleAt(tick.index / (root.ticks.length - 1)) * Math.PI / 180

            x: root.centre + root.labelRadius * Math.cos(tick.radians) - tick.width / 2
            y: root.centre + root.labelRadius * Math.sin(tick.radians) - tick.height / 2

            text: root.tickLabel(tick.modelData)
            color: root.progress > 0 && root.shown >= tick.modelData ? Colours.textBright : Colours.textMuted
            font.pixelSize: root.config.tickSize
        }
    }

    Shape {
        width: root.size
        height: root.size

        rotation: root.angleAt(root.progress)
        opacity: root.config.needleOpacity
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            strokeColor: "transparent"
            startX: root.needleOuter
            startY: root.centre - root.tipHalf

            fillGradient: LinearGradient {
                x1: root.needleInner
                x2: root.needleOuter
                y1: root.centre
                y2: root.centre

                GradientStop {
                    position: 0
                    color: Colours.textBright
                }
                GradientStop {
                    position: 1
                    color: "transparent"
                }
            }

            PathLine {
                x: root.needleInner
                y: root.centre - root.baseHalf
            }
            PathArc {
                x: root.needleInner
                y: root.centre + root.baseHalf
                radiusX: root.baseHalf
                radiusY: root.baseHalf
                direction: PathArc.Counterclockwise
            }
            PathLine {
                x: root.needleOuter
                y: root.centre + root.tipHalf
            }
        }
    }

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom

        spacing: Appearance.spacing.none

        StyledText {
            Layout.alignment: Qt.AlignHCenter

            text: root.reading.value
            color: root.live ? Colours.textBright : Colours.text
            font.pixelSize: root.config.valueSize
            font.weight: root.config.valueWeight
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter

            spacing: root.config.unitSpacing

            Icon {
                text: root.glyph
                color: root.accent
                font.pixelSize: root.config.unitGlyphSize
            }

            StyledText {
                text: root.reading.unit
                color: root.accent
                font.pixelSize: root.config.unitSize
            }
        }
    }
}
