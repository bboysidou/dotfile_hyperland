import QtQuick
import qs.core.config
import qs.core.helpers

Canvas {
    id: root

    property var gains: []
    property color colour: Colours.accent

    readonly property var config: Appearance.equalizer

    function point(index: int): var {
        const travel = root.config.sliderHeight - root.config.handleSize;
        const ratio = (root.gains[index] - root.config.gainMin) / (root.config.gainMax - root.config.gainMin);
        return {
            x: (index + 0.5) * root.width / root.gains.length,
            y: (1 - ratio) * travel + root.config.handleSize / 2
        };
    }

    onPaint: {
        const ctx = getContext("2d");
        ctx.clearRect(0, 0, width, height);
        ctx.lineJoin = "round";
        ctx.lineCap = "round";

        const time = Date.now() / 1000;
        const inset = root.config.handleSize / 2;

        for (let index = 1; index < root.gains.length; index++) {
            const start = root.point(index - 1);
            const end = root.point(index);
            Strand.link(ctx, {
                time: time,
                startX: start.x,
                startY: start.y,
                endX: end.x,
                endY: end.y,
                startInset: inset,
                endInset: inset,
                fade: 1,
                tint: root.colour,
                seed: index
            });
        }
    }

    Timer {
        interval: Appearance.orbit.strandInterval
        running: root.visible
        repeat: true

        onTriggered: root.requestPaint()
    }
}
