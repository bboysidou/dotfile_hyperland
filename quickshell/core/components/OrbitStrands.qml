import QtQuick
import qs.core.config

Canvas {
    id: root

    property Item origin: null
    property var source: null
    property color accent: Colours.accent
    property bool active: false
    property color danger: Colours.critical
    property real coreRadius: Appearance.orbit.coreSize / 2

    function strokeStrand(ctx, geometry, pass): void {
        const steps = Appearance.orbit.strandSteps;

        ctx.beginPath();
        ctx.moveTo(geometry.originX, geometry.originY);

        for (let step = 1; step <= steps; step++) {
            const progress = step / steps;
            const along = geometry.span * progress;
            const envelope = Math.sin(progress * Math.PI);
            const offset = Math.sin(geometry.time * pass.rate + progress * pass.frequency + geometry.seed) * pass.amplitude * envelope;

            ctx.lineTo(geometry.originX + geometry.cos * along - geometry.sin * offset, geometry.originY + geometry.sin * along + geometry.cos * offset);
        }

        ctx.lineWidth = pass.width;
        ctx.strokeStyle = pass.colour;
        ctx.globalAlpha = pass.alpha;
        ctx.stroke();
    }

    function drawLink(ctx, link): void {
        const orbit = Appearance.orbit;
        const dx = link.endX - link.startX;
        const dy = link.endY - link.startY;
        const distance = Math.sqrt(dx * dx + dy * dy);
        const inset = root.coreRadius + orbit.strandStartGap;
        const span = distance - inset - orbit.strandEndGap;

        if (span <= 0)
            return;

        const bearing = Math.atan2(dy, dx);
        const cos = Math.cos(bearing);
        const sin = Math.sin(bearing);
        const nearness = Math.max(0, 1 - distance / orbit.strandFalloff);
        const intensity = (orbit.strandBaseAlpha + nearness * orbit.strandDistanceAlpha) * link.fade;
        const tint = link.danger ? root.danger : root.accent;
        const thread = orbit.strandCoreWidth + nearness * orbit.strandCoreGain;

        const geometry = {
            originX: link.startX + cos * inset,
            originY: link.startY + sin * inset,
            cos: cos,
            sin: sin,
            span: span,
            time: link.time,
            seed: link.seed
        };

        root.strokeStrand(ctx, geometry, {
            amplitude: orbit.strandAmpFast,
            rate: orbit.strandWaveFast,
            frequency: orbit.strandFreqFast,
            width: orbit.strandGlowWidth + nearness * orbit.strandGlowGain,
            alpha: intensity * orbit.strandGlowAlpha,
            colour: tint
        });

        root.strokeStrand(ctx, geometry, {
            amplitude: orbit.strandAmpMid,
            rate: orbit.strandWaveMid,
            frequency: orbit.strandFreqMid,
            width: thread * 2,
            alpha: intensity * orbit.strandMidAlpha,
            colour: Qt.lighter(tint, orbit.strandMidHighlight)
        });

        root.strokeStrand(ctx, geometry, {
            amplitude: orbit.strandAmpSlow,
            rate: orbit.strandWaveSlow,
            frequency: orbit.strandFreqSlow,
            width: thread,
            alpha: intensity * orbit.strandCoreAlpha,
            colour: orbit.strandCoreColour
        });
    }

    onPaint: {
        const orbit = Appearance.orbit;
        const ctx = getContext("2d");
        ctx.clearRect(0, 0, width, height);

        if (!root.active || !root.source || !root.origin)
            return;

        ctx.lineJoin = "round";
        ctx.lineCap = "round";

        const time = Date.now() / 1000;
        const startX = root.origin.x + root.origin.width / 2;
        const startY = root.origin.y + root.origin.height / 2;

        for (let index = 0; index < root.source.count; index++) {
            const node = root.source.itemAt(index);
            if (!node || node.entry <= 0)
                continue;

            root.drawLink(ctx, {
                time: time,
                startX: startX,
                startY: startY,
                endX: node.x + node.width / 2,
                endY: node.y + node.height / 2,
                fade: node.entry * (node.linked ? 1 : orbit.strandIdleAlpha),
                danger: node.draining,
                seed: index
            });
        }
    }

    Timer {
        interval: Appearance.orbit.strandInterval
        running: root.active && root.visible
        repeat: true

        onTriggered: root.requestPaint()
    }
}
