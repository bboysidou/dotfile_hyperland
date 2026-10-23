import QtQuick
import qs.core.config
import qs.core.helpers

Canvas {
    id: root

    property real value: 0
    property color colour: Colours.accent
    property real radiusRatio: Appearance.powerPanel.ringRadiusRatio

    readonly property var config: Appearance.powerPanel

    function point(angle: real): var {
        const radius = root.width * root.radiusRatio;
        return {
            x: root.width / 2 + radius * Math.cos(angle),
            y: root.height / 2 + radius * Math.sin(angle)
        };
    }

    onPaint: {
        const ctx = getContext("2d");
        ctx.clearRect(0, 0, width, height);
        ctx.lineJoin = "round";
        ctx.lineCap = "round";

        const time = Date.now() / 1000;
        const segments = root.config.ringStrandSegments;
        const step = 2 * Math.PI / segments;
        const origin = root.config.ringStartAngle * Math.PI / 180;
        const finish = origin + Num.clamp01(root.value) * 2 * Math.PI;

        for (let index = 0; origin + index * step < finish; index++) {
            const start = root.point(origin + index * step);
            const end = root.point(Math.min(origin + (index + 1) * step, finish));
            Strand.link(ctx, {
                time: time,
                startX: start.x,
                startY: start.y,
                endX: end.x,
                endY: end.y,
                startInset: 0,
                endInset: 0,
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
