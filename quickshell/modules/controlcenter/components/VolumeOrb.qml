pragma ComponentBehavior: Bound

import QtQuick
import qs.core.components
import qs.core.config
import qs.core.helpers

Item {
    id: root

    property int percent: 0
    property bool muted: false
    property color accent: Colours.audioOutput

    readonly property color fill: root.muted ? Colours.critical : root.accent
    readonly property real ratio: Num.clamp01(root.percent / Appearance.audio.max)
    readonly property string readout: root.muted ? Appearance.audioPanel.labelMuted : Appearance.scale.percentTemplate.arg(root.percent)
    readonly property bool waving: root.visible && root.ratio > 0 && root.ratio < Appearance.audioPanel.orbFullRatio

    signal toggled
    signal scrolled(int delta)

    implicitWidth: Appearance.audioPanel.orbSize
    implicitHeight: Appearance.audioPanel.orbSize

    StyledRect {
        anchors.centerIn: parent

        width: parent.width + Appearance.audioPanel.orbGlowInset
        height: width
        radius: Appearance.audioPanel.orbRounding
        color: root.fill
        opacity: Appearance.audioPanel.orbGlowOpacity
        z: -1

        SequentialAnimation on scale {
            running: root.visible
            loops: Animation.Infinite

            NumberAnimation {
                to: Appearance.audioPanel.orbBreatheScale
                duration: Appearance.audioPanel.orbBreathePeriod
                easing.type: Easing.InOutSine
            }
            NumberAnimation {
                to: 1
                duration: Appearance.audioPanel.orbBreathePeriod
                easing.type: Easing.InOutSine
            }
        }
    }

    StyledRect {
        anchors.centerIn: parent

        width: parent.width + Appearance.audioPanel.orbRingInset
        height: width
        radius: Appearance.audioPanel.orbRounding
        color: "transparent"
        border.width: Appearance.audioPanel.orbRingWidth
        border.color: root.fill
        opacity: Appearance.audioPanel.orbRingOpacity
        z: -1
    }

    StyledRect {
        id: core

        anchors.fill: parent

        radius: Appearance.audioPanel.orbRounding
        color: Colours.elevated
        border.width: Appearance.audioPanel.orbRingWidth
        border.color: root.fill

        Canvas {
            id: liquid

            property real phase: 0

            anchors.fill: parent
            anchors.margins: Appearance.audioPanel.orbFillInset

            NumberAnimation on phase {
                running: root.waving
                loops: Animation.Infinite

                from: 0
                to: Math.PI * 2
                duration: Appearance.audioPanel.orbWavePeriod
            }

            onPhaseChanged: liquid.requestPaint()

            Connections {
                target: root

                function onRatioChanged(): void {
                    liquid.requestPaint();
                }

                function onFillChanged(): void {
                    liquid.requestPaint();
                }
            }

            onPaint: {
                const ctx = liquid.getContext("2d");
                ctx.clearRect(0, 0, liquid.width, liquid.height);

                if (root.ratio <= 0)
                    return;

                const config = Appearance.audioPanel;
                const inner = config.orbRounding - config.orbFillInset;
                const surface = liquid.height * (1 - root.ratio);

                ctx.save();
                ctx.beginPath();
                ctx.roundedRect(0, 0, liquid.width, liquid.height, inner, inner);
                ctx.clip();

                ctx.beginPath();
                ctx.moveTo(0, surface);

                if (root.ratio < config.orbFullRatio) {
                    const amplitude = config.orbWaveAmplitude * Math.sin(root.ratio * Math.PI);
                    const crest = surface + Math.sin(liquid.phase) * amplitude;
                    const trough = surface + Math.cos(liquid.phase + Math.PI) * amplitude;
                    ctx.bezierCurveTo(liquid.width * 0.33, trough, liquid.width * 0.66, crest, liquid.width, surface);
                } else {
                    ctx.lineTo(liquid.width, surface);
                }

                ctx.lineTo(liquid.width, liquid.height);
                ctx.lineTo(0, liquid.height);
                ctx.closePath();

                const gradient = ctx.createLinearGradient(0, 0, 0, liquid.height);
                gradient.addColorStop(0, Qt.lighter(root.fill, config.orbHighlight).toString());
                gradient.addColorStop(1, root.fill.toString());
                ctx.fillStyle = gradient;
                ctx.fill();
                ctx.restore();
            }
        }

        Item {
            id: submerged

            anchors.left: liquid.left
            anchors.right: liquid.right
            anchors.bottom: liquid.bottom

            readonly property real amplitude: root.ratio < Appearance.audioPanel.orbFullRatio ? Appearance.audioPanel.orbWaveAmplitude * Math.sin(root.ratio * Math.PI) : 0
            readonly property real centreOffset: 0.375 * amplitude * (Math.sin(liquid.phase) - Math.cos(liquid.phase))

            height: Num.clamp(liquid.height * root.ratio - centreOffset, 0, liquid.height)
            visible: root.ratio > 0
            clip: true

            StyledText {
                x: (liquid.width - width) / 2
                y: (liquid.height - height) / 2 - (liquid.height - submerged.height)

                text: root.readout
                color: Colours.surface
                font.pixelSize: Appearance.audioPanel.orbReadoutSize
                font.weight: Appearance.font.weightActive
            }
        }

        MouseArea {
            anchors.fill: parent

            cursorShape: Qt.PointingHandCursor

            onClicked: root.toggled()
            onWheel: event => root.scrolled(event.angleDelta.y > 0 ? Appearance.audio.step : -Appearance.audio.step)
        }
    }
}
