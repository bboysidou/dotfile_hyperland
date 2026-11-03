pragma Singleton

import QtQuick
import Quickshell
import qs.core.config
import qs.core.enums

Singleton {
    id: root

    function bent(a): bool {
        return a.cx !== undefined;
    }

    function control(a): var {
        return {
            x: a.cx ?? (a.x1 + a.x2) / 2,
            y: a.cy ?? (a.y1 + a.y2) / 2
        };
    }

    function at(a, t: real): var {
        const c = root.control(a);
        const u = 1 - t;
        return {
            x: u * u * a.x1 + 2 * u * t * c.x + t * t * a.x2,
            y: u * u * a.y1 + 2 * u * t * c.y + t * t * a.y2
        };
    }

    function samples(a): var {
        const count = Appearance.editor.curveSamples;
        return Array.from({
            length: count + 1
        }, (_, i) => root.at(a, i / count));
    }

    function trace(a): var {
        if (a.points)
            return a.points;
        return a.kind === EditTool.arrow && root.bent(a) ? root.samples(a) : null;
    }

    function towards(from, to, fallback, distance: real): var {
        const dx = to.x - from.x;
        const dy = to.y - from.y;
        const length = Math.hypot(dx, dy);
        const ux = length ? dx / length : fallback.x;
        const uy = length ? dy / length : fallback.y;
        return {
            x: from.x + ux * distance,
            y: from.y + uy * distance,
            ux: ux,
            uy: uy
        };
    }

    function head(tip, base, half: real, zoom: real): var {
        const nx = -base.uy;
        const ny = base.ux;
        return [Qt.point((base.x + nx * half) * zoom, (base.y + ny * half) * zoom), Qt.point(tip.x * zoom, tip.y * zoom), Qt.point((base.x - nx * half) * zoom, (base.y - ny * half) * zoom)];
    }

    function arrow(a, zoom: real, head): var {
        const tip = {
            x: a.x2,
            y: a.y2
        };
        const tail = {
            x: a.x1,
            y: a.y1
        };
        const c = root.control(a);
        const chord = Math.hypot(a.x2 - a.x1, a.y2 - a.y1) || 1;
        const forward = {
            x: (a.x2 - a.x1) / chord,
            y: (a.y2 - a.y1) / chord
        };
        const backward = {
            x: -forward.x,
            y: -forward.y
        };
        const twoHeads = a.style === ArrowStyle.double;
        const length = Math.min(head.length * a.width + head.min, chord * (twoHeads ? head.maxRatio / 1.5 : head.maxRatio));
        const half = (head.width * a.width + head.min) / 2;
        const inset = length * (1 - head.overlap);
        const start = twoHeads ? root.towards(tail, c, forward, inset) : tail;
        const end = root.towards(tip, c, backward, inset);
        const heads = [root.head(tip, root.towards(tip, c, backward, length), half, zoom)];
        if (twoHeads)
            heads.push(root.head(tail, root.towards(tail, c, forward, length), half, zoom));
        return {
            start: Qt.point(start.x * zoom, start.y * zoom),
            control: Qt.point(c.x * zoom, c.y * zoom),
            end: Qt.point(end.x * zoom, end.y * zoom),
            heads: heads
        };
    }
}
