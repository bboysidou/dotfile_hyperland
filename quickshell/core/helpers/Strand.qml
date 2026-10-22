pragma Singleton

import Quickshell
import qs.core.config

Singleton {
    id: root

    function stroke(ctx, geometry, pass): void {
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

    function link(ctx, link): void {
        const orbit = Appearance.orbit;
        const dx = link.endX - link.startX;
        const dy = link.endY - link.startY;
        const distance = Math.sqrt(dx * dx + dy * dy);
        const span = distance - link.startInset - link.endInset;

        if (span <= 0)
            return;

        const bearing = Math.atan2(dy, dx);
        const cos = Math.cos(bearing);
        const sin = Math.sin(bearing);
        const nearness = Math.max(0, 1 - distance / orbit.strandFalloff);
        const intensity = (orbit.strandBaseAlpha + nearness * orbit.strandDistanceAlpha) * link.fade;
        const thread = orbit.strandCoreWidth + nearness * orbit.strandCoreGain;

        const geometry = {
            originX: link.startX + cos * link.startInset,
            originY: link.startY + sin * link.startInset,
            cos: cos,
            sin: sin,
            span: span,
            time: link.time,
            seed: link.seed
        };

        root.stroke(ctx, geometry, {
            amplitude: orbit.strandAmpFast,
            rate: orbit.strandWaveFast,
            frequency: orbit.strandFreqFast,
            width: orbit.strandGlowWidth + nearness * orbit.strandGlowGain,
            alpha: intensity * orbit.strandGlowAlpha,
            colour: link.tint
        });

        root.stroke(ctx, geometry, {
            amplitude: orbit.strandAmpMid,
            rate: orbit.strandWaveMid,
            frequency: orbit.strandFreqMid,
            width: thread * 2,
            alpha: intensity * orbit.strandMidAlpha,
            colour: Qt.lighter(link.tint, orbit.strandMidHighlight)
        });

        root.stroke(ctx, geometry, {
            amplitude: orbit.strandAmpSlow,
            rate: orbit.strandWaveSlow,
            frequency: orbit.strandFreqSlow,
            width: thread,
            alpha: intensity * orbit.strandCoreAlpha,
            colour: orbit.strandCoreColour
        });
    }
}
