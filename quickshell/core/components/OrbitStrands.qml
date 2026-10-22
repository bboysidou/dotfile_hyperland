import QtQuick
import qs.core.config
import qs.core.helpers

Canvas {
    id: root

    property Item origin: null
    property var source: null
    property color accent: Colours.accent
    property bool active: false
    property color danger: Colours.critical
    property real coreRadius: Appearance.orbit.coreSize / 2

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

            Strand.link(ctx, {
                time: time,
                startX: startX,
                startY: startY,
                endX: node.x + node.width / 2,
                endY: node.y + node.height / 2,
                startInset: root.coreRadius + orbit.strandStartGap,
                endInset: orbit.strandEndGap,
                fade: node.entry * (node.linked ? 1 : orbit.strandIdleAlpha),
                tint: node.draining ? root.danger : root.accent,
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
