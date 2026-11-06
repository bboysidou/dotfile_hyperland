import QtQuick
import qs.core.components
import qs.core.config
import qs.core.enums

Canvas {
    id: root

    property real progress: 0
    property int regions: 1
    property color baseColour: Colours.trough
    property color fillColour: Colours.accent
    property real stroke: Appearance.fingerprint.glyphStroke
    property real centreRatio: Appearance.fingerprint.glyphCentreY

    readonly property var config: Appearance.fingerprint

    property real shown: root.progress

    readonly property var boundaries: {
        const lengths = root.config.ridges.map(root.ridgeLength);
        const total = lengths.reduce((sum, length) => sum + length, 0);
        let walked = 0;

        return lengths.map(length => {
            walked += length;
            return walked / total;
        });
    }

    function snap(position: real): real {
        return root.boundaries.find(boundary => Math.abs(boundary - position) < root.config.glyphSnap) ?? position;
    }

    function ridgeLength(ridge: var): real {
        return (ridge[3] - ridge[2]) * Math.PI / 180 * (ridge[0] + ridge[1]) / 2;
    }

    function trace(ctx: var, from: real, to: real): void {
        const size = Math.min(root.width, root.height);
        const centreX = root.width / 2;
        const centreY = root.height * root.centreRatio;
        const lengths = root.config.ridges.map(root.ridgeLength);
        const total = lengths.reduce((sum, length) => sum + length, 0);
        let walked = 0;

        root.config.ridges.forEach((ridge, index) => {
            const start = walked / total;
            walked += lengths[index];
            const end = walked / total;
            const low = Math.max(from, start);
            const high = Math.min(to, end);

            if (high <= low)
                return;

            const span = ridge[3] - ridge[2];
            const first = ridge[2] + span * (low - start) / (end - start);
            const last = ridge[2] + span * (high - start) / (end - start);
            const steps = Math.max(1, Math.ceil((last - first) / root.config.glyphSampleDegrees));

            ctx.beginPath();

            for (let step = 0; step <= steps; step++) {
                const angle = (first + (last - first) * step / steps) * Math.PI / 180;
                const x = centreX + Math.cos(angle) * ridge[0] * size;
                const y = centreY + Math.sin(angle) * ridge[1] * size;

                if (step === 0)
                    ctx.moveTo(x, y);
                else
                    ctx.lineTo(x, y);
            }

            ctx.stroke();
        });
    }

    function region(ctx: var, index: int, fraction: real): void {
        const from = root.snap(index / root.regions);
        const to = root.snap((index + 1) / root.regions) - root.config.glyphGap;

        root.trace(ctx, from, from + (to - from) * fraction);
    }

    onPaint: {
        const ctx = getContext("2d");

        ctx.reset();
        ctx.lineCap = "round";
        ctx.lineWidth = root.stroke;
        ctx.strokeStyle = root.baseColour;

        for (let index = 0; index < root.regions; index++)
            root.region(ctx, index, 1);

        ctx.strokeStyle = root.fillColour;

        for (let index = 0; index < root.regions; index++) {
            const fraction = Math.min(1, root.shown * root.regions - index);

            if (fraction <= 0)
                break;

            root.region(ctx, index, fraction);
        }
    }

    onShownChanged: root.requestPaint()
    onRegionsChanged: root.requestPaint()
    onFillColourChanged: root.requestPaint()
    onBaseColourChanged: root.requestPaint()
    onAvailableChanged: root.requestPaint()

    Behavior on shown {
        Anim {
            type: AnimType.standard
        }
    }
}
