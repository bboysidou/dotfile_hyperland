import QtQuick
import qs.core.config
import qs.core.helpers

Canvas {
    id: root

    property real head: 0
    property real tail: 0
    property color accent: Colours.accent

    readonly property bool drawing: root.head > root.tail

    onHeadChanged: root.requestPaint()
    onTailChanged: root.requestPaint()

    onPaint: {
        const lock = Appearance.lock;
        const orbit = Appearance.orbit;
        const ctx = getContext("2d");
        ctx.clearRect(0, 0, width, height);

        if (!root.drawing)
            return;

        ctx.lineJoin = "round";
        ctx.lineCap = "round";

        const time = Date.now() / 1000;
        const reach = width / 2;
        const middle = height / 2;
        const sides = [
            {
                edge: 0,
                direction: 1,
                seed: 0
            },
            {
                edge: width,
                direction: -1,
                seed: Math.PI
            }
        ];

        for (const side of sides) {
            const geometry = {
                originX: side.edge + side.direction * reach * root.tail,
                originY: middle,
                cos: side.direction,
                sin: 0,
                span: reach * (root.head - root.tail),
                time: time,
                seed: side.seed
            };

            Strand.stroke(ctx, geometry, {
                amplitude: orbit.strandAmpFast,
                rate: orbit.strandWaveFast,
                frequency: orbit.strandFreqFast,
                width: lock.introStrandGlowWidth,
                alpha: lock.introStrandGlowAlpha,
                colour: root.accent
            });

            Strand.stroke(ctx, geometry, {
                amplitude: orbit.strandAmpMid,
                rate: orbit.strandWaveMid,
                frequency: orbit.strandFreqMid,
                width: lock.introStrandMidWidth,
                alpha: lock.introStrandMidAlpha,
                colour: Qt.lighter(root.accent, orbit.strandMidHighlight)
            });

            Strand.stroke(ctx, geometry, {
                amplitude: orbit.strandAmpSlow,
                rate: orbit.strandWaveSlow,
                frequency: orbit.strandFreqSlow,
                width: lock.introStrandCoreWidth,
                alpha: lock.introStrandCoreAlpha,
                colour: orbit.strandCoreColour
            });

            if (root.head >= 1)
                continue;

            ctx.save();
            ctx.globalAlpha = 1;
            ctx.shadowColor = root.accent;
            ctx.shadowBlur = lock.introHeadBlur;
            ctx.fillStyle = orbit.strandCoreColour;
            ctx.beginPath();
            ctx.arc(side.edge + side.direction * reach * root.head, middle, lock.introHeadSize, 0, Math.PI * 2);
            ctx.fill();
            ctx.restore();
        }
    }

    Timer {
        interval: Appearance.lock.introRepaint
        running: root.drawing && root.visible
        repeat: true

        onTriggered: root.requestPaint()
    }
}
