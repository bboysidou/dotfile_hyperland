import QtQuick
import qs.core.config
import qs.core.helpers

Canvas {
    id: root

    property real value: 0
    property color colour: Colours.accent
    property real radiusRatio: Appearance.powerPanel.coreRingRadiusRatio

    readonly property var config: Appearance.powerPanel

    function trace(ctx, time: real, pass): void {
        const steps = root.config.ringWaveSteps;
        const radius = root.width * root.radiusRatio;
        const origin = root.config.ringStartAngle * Math.PI / 180;
        const sweep = Num.clamp01(root.value) * 2 * Math.PI;
        const taper = sweep < 2 * Math.PI ? root.config.ringWaveTaper : 0;

        ctx.beginPath();

        for (let step = 0; step <= steps; step++) {
            const along = sweep * step / steps;
            const envelope = taper > 0 ? Math.min(1, along / taper, (sweep - along) / taper) : 1;
            const angle = origin + along;
            const offset = Math.sin(time * pass.rate + angle * pass.waves) * pass.amplitude * envelope;
            const x = root.width / 2 + (radius + offset) * Math.cos(angle);
            const y = root.height / 2 + (radius + offset) * Math.sin(angle);

            if (step === 0)
                ctx.moveTo(x, y);
            else
                ctx.lineTo(x, y);
        }

        ctx.lineWidth = pass.width;
        ctx.strokeStyle = pass.colour;
        ctx.globalAlpha = pass.alpha;
        ctx.stroke();
    }

    onPaint: {
        const ctx = getContext("2d");
        ctx.clearRect(0, 0, width, height);
        ctx.lineJoin = "round";
        ctx.lineCap = "round";

        if (root.value <= 0)
            return;

        const time = Date.now() / 1000;
        const tints = [root.colour, Qt.lighter(root.colour, Appearance.orbit.strandMidHighlight), Appearance.orbit.strandCoreColour];

        root.config.ringWaves.forEach((wave, index) => root.trace(ctx, time, Object.assign({
                colour: tints[index]
            }, wave)));
    }

    Timer {
        interval: Appearance.orbit.strandInterval
        running: root.visible
        repeat: true

        onTriggered: root.requestPaint()
    }
}
